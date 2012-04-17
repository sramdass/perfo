# == Schema Information
#
# Table name: school_types
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class SchoolType < TenantManager
end
