class DailyWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    daily.hour_of_day(7)
  end

  def perform
    Person.send_daily_emails
  end
end