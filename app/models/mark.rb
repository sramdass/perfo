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
  validate :mark_should_not_be_negative_except_na_and_absent
  before_save :update_totals_credits_passed_and_arrears
  
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
      val = self.send(col_name)
      if val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)  && mc && mc.max_marks && (val > mc.max_marks)
        errors.add(col_name, "> #{ mc.max_marks}")      	
      end
    end
  end
  
  #No negative values are allowed except for the values correspond to NA and ABSENT marks
  def mark_should_not_be_negative_except_na_and_absent
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      val = self.send(col_name)
      if val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)  && (val < 0)
        errors.add(col_name, "no negatives")      	
      end
    end    	
  end  
  
  #before filters
  #---------------------------------------------------------------------------#
  #This is not used right now
  def update_total
    total = 0
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      val = self.send(col_name)
      if val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)
        total = total + val
      end
    end
    self.total=total	
  end

  #This is not used right now
  def update_arrears
    arrears = 0	
    #This will get hsh[subject_id] = 'corresponding_mark_column' in the marks table
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      mc = get_marks_criteria.for_subject(sub_id).first
      val = self.send(col_name)
      if  val && mc && mc.pass_marks && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM) && (val < mc.pass_marks)
        arrears = arrears + 1
      end
    end
    self.arrears_count=arrears
  end  
  
  #Update the total, arrears, passed subjects, weighed_total_percentage and total credits. If we have individual modules
  #for each of these, we may end up doing a lot of queries. So, club them together.
  #From the weighed_total_percentage and total_credits, we can get the weighed_total.
  def update_totals_credits_passed_and_arrears
    weighed_total = weighed_pass_total = total = arrears = total_credits = pass_credits = passed = 0
    hsh = mark_columns_with_subject_ids
    #The following will return hash[:subject_id] = credit of the subject_id
    credits = credits_with_subject_ids
    hsh.each do |sub_id, col_name|
      #mark criteria should be there. Need to see if we have to throw an exception
      #if the mark criteria is not there.
      mc = get_marks_criteria.for_subject(sub_id).first
      val = self.send(col_name)
      if val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)
      	total = total + val
      	#convert the mark value in to percentage and then multiply that value with credits.
        weighed_total = weighed_total + (( val * credits[sub_id] * 100).to_f / mc.max_marks)
        total_credits = total_credits + credits[sub_id]
      end
      if  val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)
      	if (val < mc.pass_marks)
          arrears = arrears + 1
        else 
          passed = passed + 1
          #convert the mark value in to percentage and then multiply that value with credits.
          pass_credits = pass_credits + credits[sub_id]
          weighed_pass_total = weighed_pass_total + (( val * credits[sub_id] * 100).to_f / mc.max_marks)
        end
      end      
    end
    self.arrears_count = arrears
    self.passed_count = passed
    self.total = total
    #If the total credits is 0, make the weighed percentage as 0. Otherwise, we get a divide-by-zero exception.
    self.weighed_total_percentage =  total_credits==0 ? 0 : weighed_total.to_f / total_credits
    self.weighed_pass_marks_percentage =  pass_credits==0 ? 0 : weighed_pass_total.to_f / pass_credits
    self.total_credits = total_credits
  end
  
  def is_arrear_student?
  	#if the current section_id is not equal to the current student's section_id, then he is an arrear student.
    return true if self.section_id != self.student.section_id 
    return false
  end
  	
  def arrear_student(sub_id)
  	#If this row corresponds to an arrear student, check if he has enrolled for the sub_id that is passed. Return true or false.
  	ArrearStudent.for_semester(self.semester_id).for_section(self.section_id).for_student(self.student_id).for_subject(sub_id).first
  end
  
  def get_absent_subjects_count
    abs = 0
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      val = self.send(col_name)
      abs = abs + 1 if val &&  (val == ABSENT_MARK_NUM)
    end
    return abs
  end
  
  def get_na_subjects_count
    na = 0
    hsh = mark_columns_with_subject_ids
    hsh.each do |sub_id, col_name|
      val = self.send(col_name)
      na = na + 1 if val &&  (val == NA_MARK_NUM)
    end
    return na 	
  end
  
  def get_passed_subjects_count
    self.passed_count
  end  	
  
  def get_arrear_subjects_count
    self.arrears_count
  end
  
  #Returns hash{:sub1 => x%, :sub2 => y%..etc}, #where :sub1, :sub2 are valid mark columns
  #for this particular row.
  def percentages_with_mark_columns
    h = Hash.new
    SecSubMap.for_section(section_id).for_semester(semester_id).all.each do |map|
      col_name = map.mark_column
      mc = MarkCriteria.for_section(self.section_id).for_semester(self.semester_id).for_exam(exam_id).for_subject(map.subject_id).first
      max_marks = mc.max_marks if mc
      val = self.send(col_name)
      #the val (mark value) can be null for the arrear students. Also if the teacher does not enter the marks, it will be nil.
      #So, check for null.
      if max_marks && val && (val != NA_MARK_NUM) && (val != ABSENT_MARK_NUM)
        h[col_name] = (val.to_f / max_marks) * 100
      else
        h[col_name] = "NA"
      end
    end
    return h
  end  
  
  def percentiles_with_mark_colulmns
  	h = Hash.new
    marks_rel = Mark.for_section(self.section_id).for_semester(self.semester_id).for_exam(self.exam_id).select("id, #{col_name}").order("#{col_name} ASC")
    SecSubMap.for_section(section_id).for_semester(semester_id).all.each do |map|
      col_name = map.mark_column
      marks = marks_rel.select("id, #{col_name}").order("#{col_name} ASC")
      #the x.send(col_name ) (mark value) can be null for the arrear students. Also if the teacher does not 
      #enter the marks, it will be nil. Delete the nil marks to the list.
      marks.delete_if { |x| x.send(col_name) == NA_MARK_NUM ||  x.send(col_name) == ABSENT_MARK_NUM || !x.send(col_name) }
      index = Hash[marks.map.with_index{ |*ki|  ki } ]
      count = marks.count
      mark = mark_rel.for_student(self.student_id).first
      h[col_name] = ((index[mark] + 1) *100).to_f / marks.count
    end
    return h
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
  
  def credits_with_subject_ids
    h = Hash.new
    SecSubMap.for_section(section_id).for_semester(semester_id).all.each do |map|
      name =map.subject_id
      h[name] = map.credits || 1
    end
    return h
  end	  
  
  #Returns the max marks for a section + exam + subject combo.
  def get_marks_criteria
    MarkCriteria.for_section(section_id).for_exam(exam_id).for_semester(semester_id)
  end    
  
  #CLASS Modules
  #---------------------------------------------------------------------------#
  # To find the total of all the student marks for  a section + exam + subject combo.
  def self.total_on(section_id, subject_id, exam_id)
   column_name = SecSubMap.by_section_id(section_id).by_subject_id(subject_id).first.mark_column
   where('section_id = ? and exam_id = ?', section_id, exam_id).sum(column_name.to_sym)
  end
  
  def self.total_on_column(ar_relation, col_name)
  	ar_relation.sum(col_name)
  end
  
  def self.subject_percentiles_with_mark_ids(col_name, section_id, semester_id, exam_id)
  	h = Hash.new
    marks = Mark.for_section(section_id).for_semester(semester_id).for_exam(exam_id).select("id, #{col_name}").order("#{col_name} ASC")
    #x.send(col_name) (mark value) can be null for the arrear students. Also if the teacher does not 
    #enter the marks, it will be nil. Delete the nil marks to the list.    
    marks.delete_if { |x| x.send(col_name) == NA_MARK_NUM ||  x.send(col_name) == ABSENT_MARK_NUM  || !x.send(col_name) }
    index = Hash[marks.map.with_index{ |*ki|  ki } ]
    count = marks.count
    marks.each do |mark|
      h[mark.id] = ((index[mark] + 1) *100).to_f / marks.count
    end
    return h
  end
  
  def self.weighed_total_percentiles_with_mark_ids(section_id, semester_id, exam_id)
  	Mark.subject_percentiles_with_mark_ids("weighed_total_percentage", section_id, semester_id, exam_id)
  end
  
  def self.weighed_pass_marks_percentiles_with_mark_ids(section_id, semester_id, exam_id)
  	Mark.subject_percentiles_with_mark_ids("weighed_pass_marks_percentage", section_id, semester_id, exam_id)
  end
  
end
