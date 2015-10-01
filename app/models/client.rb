# == Schema Information
#
# Table name: clients
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  address    :string(255)
#  notes      :text
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  enabled    :boolean          default(TRUE)
#

class Client < ActiveRecord::Base
  has_many :projects, -> { order "projects.name ASC" }
  belongs_to :company

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  attr_accessor :person_projects

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company }

  include Reportable

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << [
        "Client Name",
        "Address"
      ]
      all.each do |client|
        # csv << client.attributes.values_at(*column_names)
        csv << [
          client.name, # Client Name
          client.address # Address
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
      if row["Client Name"].nil?
        errors << "Incorrect format from line #{index}: #{row}"
      else
        client = Client.find_by(company: company, name: row["Client Name"])
        if client.nil?
          Client.create!({
            company: company,
            name: row["Client Name"],
            address: row["Address"]
            })
          success << "Client imported from line #{index}: #{row["Client Name"]}"
        else
          errors << "Existent client from line #{index}: #{row["Client Name"]}"
        end
      end
    end
    return [success, errors]
  end

  def time_entered
    TimeEntry.where(project: self.projects).sum(:hours)
  end

  def projects_enabled
    self.projects.enabled
  end

  def report_time_entered(from, to, clients, projects, tasks, people, person)
    handle_params(from, to, clients, projects, tasks, people, person)
    TimeEntry.joins(project: :client).where(spent_on: from..to, clients: { id: self.id }, project: @projects_ids, task: @tasks_ids, person: @people_ids).sum(:hours)
  end

end
