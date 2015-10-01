# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  notes      :text
#  common     :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#

class Task < ActiveRecord::Base
  belongs_to :company
  has_many :task_assignments, dependent: :destroy
  has_many :projects, -> { order "projects.name ASC" }, through: :task_assignments
  has_many :time_entries, -> { order "created_at ASC" }, dependent: :destroy
  has_many :rows, -> { order "stored_at DESC" }, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company }

  include Reportable

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << [
        "Task name",
        "Common",
        "Task Notes"]
      all.each do |task|
        # csv << client.attributes.values_at(*column_names)
        csv << [
          task.name, # Task name
          task.common, # Common
          task.notes # Task Notes
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
      if row["Task name"].nil?
        errors << "Incorrect format from line #{index}: #{row}"
      else
        task = Task.find_by(company: company, name: row["Task name"])
        if task.nil?
          if row["Common"].nil? or row["Common"] == 'false'
            common = false
          else
            common = true
          end
          Task.create!({
            company: company,
            name: row["Task name"],
            common: common,
            notes: row["Task Notes"]
            })
          success << "Task imported from line #{index}: #{row["Task name"]}"
        else
          errors << "Existent task from line #{index}: #{row["Task name"]}"
        end
      end
    end
    return [success, errors]
  end

  def time_entered
    hours = 0.0
    self.time_entries.each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def report_time_entered(from, to, clients, projects, tasks, people, person)
    handle_params(from, to, clients, projects, tasks, people, person)
    TimeEntry.joins(project: :client).where(spent_on: from..to, clients: { id: @clients_ids }, project: @projects_ids, task: self, person: @people_ids).sum(:hours)
  end

end
