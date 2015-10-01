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

require 'rails_helper'

RSpec.describe Reminder, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
