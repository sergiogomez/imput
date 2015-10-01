class PersonMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: "imput.io <team@imput.io>", css: 'email'
  layout 'email'

  def timer_started(time_entry_id)
    @time_entry = TimeEntry.find(time_entry_id)
    @person = @time_entry.person
    mail(to: @person.email, subject: "You have just started a timer")
  end

  def timer_running(time_entry_id)
    @time_entry = TimeEntry.find(time_entry_id)
    @person = @time_entry.person
    @time_running = (@time_entry.hours + (DateTime.now.to_f - @time_entry.begun_on.to_f)/3600).round(2)
    mail(to: @person.email, subject: "You have a timer running")
  end

  def last_day(person_id)
    @person = Person.find(person_id)
    @time_entries = TimeEntry.where(person: @person, spent_on: Date.yesterday)
    mail(to: @person.email, subject: "Your time entries for yesterday") if @time_entries.size > 0
  end
  
end
