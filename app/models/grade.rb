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
	
  def self.get_color_code(percentage)
    Grade.order('cut_off_percentage ASC').all.each do |grade|
      if percentage >= grade.cut_off_percentage
        return grade.color_code	
      end
    end
    return 'red'
  end
end
