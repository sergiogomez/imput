class ReminderWorker
  include Sidekiq::Worker
 
  def perform(args)
    reminder = Reminder.find(args['id'])
    if !reminder.nil?
      reminder.time_entry.notified = true
      reminder.time_entry.save
      PersonMailer.delay.timer_running(reminder.time_entry.id)
      reminder.destroy
    end
  end
end