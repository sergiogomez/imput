# == Schema Information
#
# Table name: companies
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  notes              :text
#  created_at         :datetime
#  updated_at         :datetime
#  billing_email      :string(255)
#

class Company < ActiveRecord::Base
  has_many :people, -> { order "people.firstname ASC" }, dependent: :destroy
  has_many :projects, -> { order "projects.name ASC" }, dependent: :destroy
  has_many :clients, -> { order "clients.name ASC" }, dependent: :destroy
  has_many :tasks, -> { order "tasks.name ASC" }, dependent: :destroy

  validates :name, presence: true

  def common_tasks
    Task.where(common: true, company: self).order(name: :asc)
  end

  def other_tasks
    Task.where(common: false, company: self).order(name: :asc)
  end

  def grouped_tasks
    common = self.common_tasks
    other = self.other_tasks
    [common, other]
  end

  def time_entries
    TimeEntry.where(project: self.projects)
  end

  def time_entries_sum
    self.time_entries.sum(:hours)
  end

  def admins
    Person.where(company: self, admin: true)
  end

end
