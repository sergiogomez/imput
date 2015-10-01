# == Schema Information
#
# Table name: task_assignments
#
#  id         :integer          not null, primary key
#  notes      :text
#  task_id    :integer
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class TaskAssignment < ActiveRecord::Base
  belongs_to :task
  belongs_to :project
end
