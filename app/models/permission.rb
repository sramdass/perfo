# == Schema Information
#
# Table name: permissions
#
#  id          :integer         not null, primary key
#  role_id     :integer
#  resource_id :integer
#  privilege   :integer
#  constraints :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Permission < ActiveRecord::Base
  belongs_to :resource
  belongs_to :role
end
