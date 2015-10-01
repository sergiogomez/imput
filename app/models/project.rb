# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  notes      :text
#  client_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  enabled    :boolean          default(TRUE)
#

class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :company
  has_many :members, dependent: :destroy
  has_many :people, -> { order "firstname ASC" }, through: :members
  has_many :task_assignments, dependent: :destroy
  has_many :tasks, -> { order "tasks.name ASC" }, through: :task_assignments
  has_many :time_entries, -> { order "created_at ASC" }, dependent: :destroy
  has_many :rows, -> { order "stored_at DESC" }, dependent: :destroy

  has_many :project_managers, -> { where members: { project_manager: true } }, through: :members, source: :person

  include Reportable

  def self.enabled
    joins(:client).where(enabled: true, clients: { enabled: true })
  end

  def self.disabled
    joins(:client).where("projects.enabled = false OR (projects.enabled = true AND clients.enabled = false)")
  end

  attr_accessor :available_tasks

  validates :name, :client, :tasks, :people, presence: true
  validates :name, uniqueness: { scope: :company }

  def self.bigger
    self.all.sort_by(&:time_entered).reverse
  end

  def self.person_bigger(person)
    person.projects.sort { |a,b| a.person_time_entered(person) <=> b.person_time_entered(person) }.reverse
  end

  def time_entered
    hours = 0.0
    self.time_entries.each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def person_time_entered(person)
    hours = 0.0
    TimeEntry.where(person: person, project: self).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def proportional_time_entered(max)
    (self.time_entered/max * 100).round(0) if max > 0
  end

  def proportional_person_time_entered(person, max)
    (self.person_time_entered(person)/max * 100).round(0) if max > 0
  end

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << [
        "Client Name",
        "Project Name",
        "Project Notes"
      ]
      all.each do |project|
        # csv << client.attributes.values_at(*column_names)
        csv << [
          project.client.name, # Client Name
          project.name, # Project Name
          project.notes # Project Notes
        ]
      end
    end
  end

  def self.import(current_person, file)
    errors = []
    success = []
    index = 0
    company = current_person.company
    CSV.foreach(file.path, headers: true) do |row|
      index += 1
      if row["Client Name"].nil? or row["Project Name"].nil?
        errors << "Incorrect format from line #{index}: #{row}"
      else
        client = Client.find_by(name: row["Client Name"], company: company)
        if client.nil?
          client = Client.create!(name: row["Client Name"], company: company)
          success << "Client imported from line #{index}: #{row["Client Name"]}"
        end
        if !client.nil?
          project = Project.find_by(name: row["Project Name"], company: company)
          if project.nil?
            Project.create!({
              client: client,
              company: company,
              name: row["Project Name"],
              notes: row["Project Notes"],
              tasks: company.common_tasks,
              people: [current_person]
              })
            success << "Project imported from line #{index}: #{row["Project Name"]}"
          else
            errors << "Existent project from line #{index}: #{row["Project Name"]}"
          end
        end
      end
    end
    return [success, errors]
  end

  def report_time_entered(from, to, clients, projects, tasks, people, person)
    handle_params(from, to, clients, projects, tasks, people, person)
    TimeEntry.joins(project: :client).where(spent_on: from..to, clients: { id: @clients_ids }, project: self, task: @tasks_ids, person: @people_ids).sum(:hours)
  end

end
