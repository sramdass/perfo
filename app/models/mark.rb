# == Schema Information
#
# Table name: marks
#
#  id            :integer         not null, primary key
#  student_id    :integer
#  semester_id   :integer
#  section_id    :integer
#  exam_id       :integer
#  sub1          :float
#  sub2          :float
#  sub3          :float
#  sub4          :float
#  sub5          :float
#  sub6          :float
#  sub7          :float
#  sub8          :float
#  sub9          :float
#  sub10         :float
#  sub11         :float
#  sub12         :float
#  sub13         :float
#  sub14         :float
#  sub15         :float
#  sub16         :float
#  sub17         :float
#  sub18         :float
#  sub19         :float
#  sub20         :float
#  total         :float
#  grade         :string(255)
#  arrears_count :string(255)
#  comments      :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Mark < TenantManager
  belongs_to :section
  validates_presence_of :section
  validates_associated :section

  belongs_to :student
  validates_presence_of :student
  validates_associated :student
  
  belongs_to :semester
  validates_presence_of :semester
  validates_associated :semester
  
  belongs_to :exam
  validates_presence_of :semester
  validates_associated :semester
  
  validates_numericality_of :sub1, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub2, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub3, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub4, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub5, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub6, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub7, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub8, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub9, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub10, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub11, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub12, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub13, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub14, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub15, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub16, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub17, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub18, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub19, :allow_nil => true, :message => "invalid"
  validates_numericality_of :sub20,:allow_nil => true, :message => "invalid"
  
  
  validate :mark_should_not_be_greater_than_max_marks
  before_save :update_total, :update_arrears  
  
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  scope :for_student, lambda { |student_id| where('student_id = ? ', student_id)}     
  scope :for_exam, lambda { |exam_id| where('exam_id = ? ', exam_id)}         
  
   #Validations
  #---------------------------------------------------------------------------#
  def mark_should_not_be_greater_than_max_marks  
    #This will get hsh[subject_id] = 'corresponding_mark_column' in the marks table
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      mc = get_marks_criteria.for_subject(sub_id).first
      if self.send(col_name) && mc && mc.max_marks && (self.send(col_name) > mc.max_marks)
        errors.add(col_name, "> #{ mc.max_marks}")      	
      end
    end
  end
  
  #before filters
  #---------------------------------------------------------------------------#
  def update_total
    total = 0
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      if self.send(col_name)
        total = total + self.send(col_name)
      end
    end
    self.total=total	
  end

  def update_arrears
    arrears = 0	
    #This will get hsh[subject_id] = 'corresponding_mark_column' in the marks table
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      mc = get_marks_criteria.for_subject(sub_id).first
      if self.send(col_name) && mc && mc.pass_marks && (self.send(col_name) < mc.pass_marks)
        arrears = arrears + 1
      end
    end
   self.arrears_count=arrears
   end  
  
  #Helper Module
  #---------------------------------------------------------------------------#
  #This will return a hash with each of the subject id of the section as the key and the corresponding mark column as the value
  def mark_columns_with_subject_ids
    h = Hash.new
    SecSubMap.for_section(section_id).for_semester(semester_id).all.each do |map|
      name =map.subject_id
      h[name] = map.mark_column
    end
    return h
  end	
  
  #CLASS Modules
  #---------------------------------------------------------------------------#
  # To find the total of all the student marks for  a section + exam + subject combo.
  def self.total_on(section_id, subject_id, exam_id)
   column_name = SecSubMap.by_section_id(section_id).by_subject_id(subject_id).first.mark_column
   where('section_id = ? and exam_id = ?', section_id, exam_id).sum(column_name.to_sym)
  end
  
  #Returns the max marks for a section + exam + subject combo.
  def get_marks_criteria
    MarkCriteria.for_section(section_id).for_exam(exam_id).for_semester(semester_id)
  end  
  
end
