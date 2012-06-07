# == Schema Information
#
# Table name: grades
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  color_code         :string(255)
#  cut_off_percentage :float
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Grade < ActiveRecord::Base
end
