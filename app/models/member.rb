# == Schema Information
#
# Table name: members
#
#  id              :integer          not null, primary key
#  notes           :text
#  person_id       :integer
#  project_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  project_manager :boolean          default(FALSE)
#

class Member < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
end
