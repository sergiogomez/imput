# == Schema Information
#
# Table name: people
#
#  id                     :integer          not null, primary key
#  firstname              :string(255)
#  lastname               :string(255)
#  notes                  :text
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  company_id             :integer
#  admin                  :boolean          default(FALSE)
#  current_time_entry_id  :integer
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  receive_daily_report   :boolean          default(FALSE)
#  time_decimal           :boolean          default(TRUE)
#  enabled                :boolean          default(TRUE)
#  authentication_token   :string(255)
#  max_hours              :float            default(8.0)
#

class Person < ActiveRecord::Base
  has_many :members, dependent: :destroy
  has_many :projects, -> { order "projects.name ASC" }, through: :members
  has_many :time_entries, -> { order "created_at ASC" }, dependent: :destroy
  has_one :current_time_entry, class_name: "TimeEntry", foreign_key: "active_person_id"
  belongs_to :company
  has_many :rows, -> { order "stored_at DESC" }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  attr_accessor :company_name

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :async

  validates :firstname, :lastname, :email, presence: true
  validates :company_name, presence: true, on: :create
  validates :max_hours, presence: true, on: :update
  validates :password, confirmation: true

  include Reportable

  before_save :ensure_authentication_token

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def renew_authentication_token
    self.authentication_token = generate_authentication_token
    self.save
    return self.authentication_token
  end

  def fullname
    firstname + ' ' + lastname
  end

  def name
    fullname
  end

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << [
        "First Name",
        "Last Name",
        "Email",
        "Admin"
      ]
      all.each do |person|
        # csv << client.attributes.values_at(*column_names)
        csv << [
          person.firstname, # First Name
          person.lastname, # Last Name
          person.email, # Email
          person.admin # Admin
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
      if row["First Name"].nil? or row["Last Name"].nil? or row["Email"].nil?
        errors << "Incorrect format from line #{index}: #{row}"
      else
        person = Person.find_by(email: row["Email"])
        if person.nil?
          generated_password = Devise.friendly_token.first(8)
          person = Person.create!({
            company: company,
            company_name: company.name,
            firstname: row["First Name"],
            lastname: row["Last Name"],
            email: row["Email"],
            password: generated_password
            })
          success << "People created from line #{index}: Email: #{row["Email"]}, Password: #{generated_password} (please change it!)"
        else
          errors << "Existent people from line #{index}: #{row["First Name"]} #{row["Last Name"]}"
        end
      end
    end
    return [success, errors]
  end

  def tasks
    tasks = []
    self.projects.enabled.each do |project|
      project.tasks.each do |task|
        tasks << task
      end
    end
    tasks
  end

  def tasks_in_a_row(selected_date)
    tasks = []
    self.projects.enabled.each do |project|
      project.tasks.each do |task|
        tasks << task if Row.find_by(person: self, stored_at: selected_date.beginning_of_week, project: project, task: task)
      end
    end
    tasks
  end

  def tasks_not_in_a_row(selected_date)
    tasks = []
    self.projects.enabled.each do |project|
      project.tasks.each do |task|
        tasks << task unless Row.find_by(person: self, stored_at: selected_date.beginning_of_week, project: project, task: task)
      end
    end
    tasks
  end

  def last_time_entry
    if self.current_time_entry.nil?
      TimeEntry.where(person: self, is_adjust: false).order(updated_at: :desc).first
    else
      self.current_time_entry
    end
  end

  def dashboard_last_time_entry
    time_entry = TimeEntry.where(person: self, is_adjust: false, spent_on: Date.today).order(updated_at: :desc).first
    time_entry = TimeEntry.where(person: self, is_adjust: false).order(updated_at: :desc).first if time_entry.nil?
    return time_entry
  end

  def last_day_time_entries
    time_entries = TimeEntry.where(person: self, is_adjust: false, project: self.company.projects.enabled.ids)
    if time_entries.size > 0
      last_day = time_entries.order(spent_on: :desc).first.spent_on
      TimeEntry.where(person: self, is_adjust: false, project: self.company.projects.enabled.ids).where(spent_on: last_day).order(created_at: :asc)
    else
      []
    end
  end

  def last_week_rows
    rows = Row.where(person: self, project: self.company.projects.enabled.ids)
    if rows.size > 0
      last_week = Row.where(person: self).order(stored_at: :desc).first.stored_at
      Row.where(person: self, project: self.company.projects.enabled.ids).where(stored_at: last_week).order(created_at: :asc)
    else
      []
    end
  end

  def clients
    Client.joins(:projects).where(company: self.company, projects: { id: self.project_ids }).order(name: :asc)
  end

  def time_entered
    TimeEntry.where(person: self).sum(:hours)
  end

  def managed_projects
    self.projects.enabled.where(company: self.company, members: { project_manager: true })
  end

  def managed_clients
    Client.joins(:projects).where(company: self.company, projects: { id: self.managed_projects }).distinct
  end

  def clients_for_reports
     admin? ? company.clients : managed_clients
  end

  def projects_for_reports
   admin? ? company.projects : managed_projects
  end

  def max_time_entry(day)
    time_entries = TimeEntry.where(person: self, spent_on: day).select(:project_id, :task_id, "sum(hours) as total_hours").group(:project_id, :task_id).order("total_hours DESC")
    max_hours = time_entries.first.total_hours.round(2) unless time_entries.first.nil?
  end

  def max_week_time_entry(day)
    time_entries = TimeEntry.where(person: self, spent_on: day.beginning_of_week..day.end_of_week).select(:project_id, :task_id, "sum(hours) as total_hours").group(:project_id, :task_id).order("total_hours DESC")
    max_hours = time_entries.first.total_hours.round(2) unless time_entries.first.nil?
  end

  def self.send_daily_emails
    people = Person.where(receive_daily_report: true)
    people.each do |person|
      PersonMailer.delay.last_day(person.id)
    end
  end

  def active_for_authentication?
    super and self.enabled?
  end

  def percent_projects(interval = nil)
    projects = {}
    self.projects.enabled.each do |project|
      if interval == 'all'
        hours = TimeEntry.where(person: self, project: project).sum(:hours)
      else
        hours = TimeEntry.where(person: self, project: project, spent_on: (Date.today - eval("1.#{interval}"))..Date.today).sum(:hours)
      end
      hours = 0.001 if hours == 0
      projects[project.name] = hours #if hours > 0
    end
    return projects
  end

  def percent_tasks(interval = nil)
    tasks = {}
    self.tasks.each do |task|
      if interval == 'all'
        hours = TimeEntry.where(person: self, task: task).sum(:hours)
      else
        hours = TimeEntry.where(person: self, task: task, spent_on: (Date.today - eval("1.#{interval}"))..Date.today).sum(:hours)
      end
      hours = 0.001 if hours == 0
      tasks[task.name] = hours #if hours > 0
    end
    return tasks
  end

  def percent_clients(interval = nil)
    clients = {}
    self.clients.enabled.each do |client|
      if interval == 'all'
        hours = TimeEntry.where(person: self, project: client.projects).sum(:hours)
      else
        hours = TimeEntry.where(person: self, project: client.projects, spent_on: (Date.today - eval("1.#{interval}"))..Date.today).sum(:hours)
      end
      hours = 0.001 if hours == 0
      clients[client.name] = hours #if hours > 0
    end
    return clients
  end

  def report_time_entered(from, to, clients, projects, tasks, people, person)
    handle_params(from, to, clients, projects, tasks, people, person)
    TimeEntry.joins(project: :client).where(spent_on: from..to, clients: { id: @clients_ids }, project: @projects_ids, task: @tasks_ids, person: self).sum(:hours)
  end

  private

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless Person.where(authentication_token: token).first
      end
    end

end
