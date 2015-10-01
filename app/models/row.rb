# == Schema Information
#
# Table name: rows
#
#  id         :integer          not null, primary key
#  person_id  :integer
#  project_id :integer
#  task_id    :integer
#  stored_at  :date
#  created_at :datetime
#  updated_at :datetime
#

class Row < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
  belongs_to :task

  def duplicate
    new_row = Row.new
    new_row.person_id = self.person.id
    new_row.project = self.project
    new_row.task = self.task
    return new_row
  end

  def time_entries(person)
    TimeEntry.where(person: person, spent_on: self.stored_at.beginning_of_week..self.stored_at.end_of_week, project: self.project, task: self.task)
  end
end
