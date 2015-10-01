# == Schema Information
#
# Table name: reminders
#
#  id            :integer          not null, primary key
#  text          :string(255)
#  notify_at     :datetime
#  job_id        :string(255)
#  time_entry_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Reminder < ActiveRecord::Base
  belongs_to :time_entry

  after_create :add_sidekiq_job
  before_destroy :remove_sidekiq_job

  def add_sidekiq_job
    id = ReminderWorker.perform_at(notify_at, {id: self.id.to_s})
    self.update_attributes(job_id: id)
  end

  def remove_sidekiq_job
    queue =  Sidekiq::ScheduledSet.new
    job = queue.find_job(self.job_id)
    job.delete if job
  end

  def scheduled_at
    notify_at.to_time.to_i - Time.now.to_i
  end

end
