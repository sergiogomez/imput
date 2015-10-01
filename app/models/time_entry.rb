# == Schema Information
#
# Table name: time_entries
#
#  id               :integer          not null, primary key
#  hours            :float
#  spent_on         :date
#  begun_on         :datetime
#  person_id        :integer
#  project_id       :integer
#  task_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timer_running    :boolean          default(FALSE)
#  active_person_id :integer
#  notes            :text
#  is_adjust        :boolean          default(FALSE)
#  notified         :boolean          default(FALSE)
#

class TimeEntry < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
  belongs_to :task
  belongs_to :active_person, class_name: "Person"
  has_one :reminder, dependent: :destroy

  after_create :create_row
  after_update :create_row
  after_create :check_timer

  validates :hours, numericality: true, allow_nil: true
  validates :hours, presence: true, on: :update
  validates :project, :task, presence: true

  def self.get_time_entry(person, spent_on, project, task)
    hours = 0.0
    TimeEntry.where(person: person, spent_on: spent_on, project: project, task: task).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def self.get_stopped_time_entry(person, spent_on, project, task)
    hours = 0.0
    TimeEntry.where(person: person, spent_on: spent_on, project: project, task: task, timer_running: false).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def self.adjust_time_entry(person, spent_on, project, task, hours)
    current_hours = TimeEntry.get_stopped_time_entry(person, spent_on, project, task)
    set_hours = (hours - current_hours).round(2)
    if set_hours != 0
      t = TimeEntry.find_by(person: person, spent_on: spent_on, project: project, task: task, is_adjust: true)
      if t.nil?
        t = TimeEntry.new(person: person, spent_on: spent_on, project: project, task: task, is_adjust: true, hours: set_hours)
      else
        t.hours += set_hours
      end
      if t.hours != 0
        t.save
      else
        t.destroy
      end
    end
  end

  def self.week_task_time(person, spent_on, project, task)
    hours = 0.0
    (0..6).each do |n|
      TimeEntry.where(person: person, spent_on: spent_on + n, project: project, task: task).each do |time_entry|
        hours += time_entry.hours
      end
    end
    hours.round(2)
  end

  def self.day_time(person, spent_on)
    hours = 0.0
    TimeEntry.where(person: person, spent_on: spent_on).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def self.week_total_time(person, spent_on)
    hours = 0.0
    (0..6).each do |n|
      TimeEntry.where(person: person, spent_on: spent_on + n).each do |time_entry|
        hours += time_entry.hours
      end
    end
    hours.round(2)
  end

  def self.month_total_time(person, spent_on)
    hours = 0.0
    TimeEntry.where(person: person, spent_on: (spent_on.beginning_of_month)..(spent_on.end_of_month)).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def self.quarter_total_time(person, spent_on)
    hours = 0.0
    TimeEntry.where(person: person, spent_on: (spent_on.beginning_of_quarter)..(spent_on.end_of_quarter)).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def stop
    self.reminder.destroy if self.reminder
    self.timer_running = false
    self.hours += ((DateTime.now.to_f - self.begun_on.to_f)/3600).round(2)
    self.person.current_time_entry = nil
  end

  def start
    self.person.current_time_entry.stop unless self.person.current_time_entry.nil?
    self.timer_running = true
    self.begun_on = DateTime.now
    self.person.current_time_entry = self
    self.hours ||= 0
    if !self.notified
      if self.person.max_hours > self.hours
        notify_at = self.begun_on + (self.person.max_hours.hours - self.hours * 3600)
      else
        notify_at = self.begun_on + 24.hours
      end
      Reminder.create!(text: "Timer running", notify_at: notify_at, time_entry: self)
    end
  end

  def duplicate
    new_time_entry = TimeEntry.new
    new_time_entry.person_id = self.person.id
    new_time_entry.spent_on = Date.today
    new_time_entry.hours = 0
    new_time_entry.project = self.project
    new_time_entry.task = self.task
    new_time_entry.notes = self.notes
    return new_time_entry
  end

  def duplicate_and_start
    new_time_entry = self.duplicate
    if self.timer_running
      self.stop
      self.save
    end
    new_time_entry.start
    return new_time_entry
  end

  def self.project_total_time(person, project)
    hours = 0.0
    TimeEntry.where(person: person, project: project).each do |time_entry|
      hours += time_entry.hours
    end
    hours.round(2)
  end

  def create_row
    Row.find_or_create_by(person: self.person, project: self.project, task: self.task, stored_at: self.spent_on.beginning_of_week)
  end

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << [
        "Date",
        "Client",
        "Project",
        "Task",
        "Hours",
        "First Name",
        "Last Name"
      ]
      all.each do |time_entry|
        # csv << client.attributes.values_at(*column_names)
        csv << [
          time_entry.spent_on, # Date
          time_entry.project.client.name, # Client
          time_entry.project.name, # Project
          time_entry.task.name, # Task
          time_entry.hours, # Hours
          time_entry.person.firstname, # First Name
          time_entry.person.lastname # Last Name
        ]
      end
    end
  end

  def self.import(current_person, file)
    errors = []
    success = []
    index = 0
    time_entries = 0
    manually_people = []
    company = current_person.company
    CSV.foreach(file.path, headers: true) do |row|
      index += 1
      if row["Date"].nil? or row["Client"].nil? or row["Project"].nil? or row["Task"].nil? or row["Hours"].nil? or row["First Name"].nil? or row["Last Name"].nil?
        errors << "Incorrect format from line #{index}: #{row}"
      else
        person = Person.find_by(firstname: row["First Name"], lastname: row["Last Name"], company: company)
        if !person.nil?

          task = Task.find_by(name: row["Task"], company: company)
          if task.nil?
            task = Task.create!(name: row["Task"], company: company)
            success << "Task imported from line #{index}: #{row["Task"]}"
          end

          client = Client.find_by(name: row["Client"], company: company)
          if client.nil?
            client = Client.create!(name: row["Client"], company: company)
            success << "Client imported from line #{index}: #{row["Client"]}"
          end

          project = Project.find_by(name: row["Project"], company: company)
          if project.nil? and !client.nil?
            project = Project.create!(name: row["Project"], client: client, company: company, tasks: [task], people: [person])
            success << "Project imported from line #{index}: #{row["Project"]}"
          end

          if !project.nil?
            if !project.people.include? person
              project.people << person
              project.save
            end
            if !project.tasks.include? task
              project.tasks << task
              project.save
            end
            if TimeEntry.create!({
              hours: row["Hours"].gsub(',', '.').to_f,
              spent_on: row["Date"].to_date,
              person: person,
              project: project,
              task: task
              })
              time_entries += 1
            end
          end
        else
          if !manually_people.include? "#{row["First Name"]} #{row["Last Name"]}"
            manually_people << "#{row["First Name"]} #{row["Last Name"]}"
            errors << "You need to create manually this person from line #{index}: #{row["First Name"]} #{row["Last Name"]}"
          end
        end
      end
    end
    return [success, errors, time_entries]
  end

  private

    def check_timer
      if self.hours.nil?
        self.hours = 0
        self.start
        self.save
      end
    end

end
