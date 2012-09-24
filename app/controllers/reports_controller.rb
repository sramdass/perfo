class ReportsController < ApplicationController
	
  def index
    @batches = Batch.all
    @departments = Department.all
    @semesters = Semester.all
    
    @department = Department.find(params[:department_id]) if params[:department_id] && params[:department_id].length != 0
    @batch = Batch.find(params[:batch_id]) if params[:batch_id] && params[:batch_id].length != 0
    @section= Section.find(params[:section_id]) if params[:section_id] && params[:section_id].length != 0
    @student= Student.find(params[:student_id]) if params[:student_id] && params[:student_id].length != 0
    @semester= Semester.find(params[:semester_id]) if params[:semester_id] && params[:semester_id].length != 0
    @exam= Exam.find(params[:exam_id]) if params[:exam_id] && params[:exam_id].length != 0
    
    if @student && @semester && @exam
      @marks = one_student_one_semester_one_exam
    elsif @student && @semester
      @marks = one_student_one_semester_all_exams
    elsif @student
    
    #we do not need the exam here. the exam should default to semester final exam
    elsif @department && @semester && @exam
      @marks = get_department_marks_with_batch    
    elsif @batch && @semester && @exam
      @marks = get_batch_marks_with_department
    elsif @batch && @department && @exam && @semester
      @marks = get_batch_marks_with_section
    elsif @batch

	elsif @section && @semester && @exam
      @marks = get_section_marks(params)
    end
    	
  end
  
  def get_section_marks(params)
  	ret_val = []
    marks = Mark.for_section(@section.id).for_semester(@semester.id).for_exam(@exam.id)
    marks.each do |mark_row|
      temp_hash = {}
      total_credits = 0
      total_percentage=0
      temp_hash['student_name'] = mark_row.student.name
      temp_hash['subjects'] = {}
      percentages = mark_row.percentages_with_mark_columns
      percentiles = {}
      weighed_total_percentiles = Mark.weighed_total_percentiles_with_mark_ids(@section.id, @semester.id, @exam.id)
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
	    percentiles[ssmap.mark_column] = Mark.subject_percentiles_with_mark_ids(ssmap.mark_column, @section.id, @semester.id, @exam.id)
      end      
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
      	temp_hash['subjects'][ssmap.mark_column] = {}
      	m = mark_row.send(ssmap.mark_column.to_sym)
      	if m == NA_MARK_NUM || m == ABSENT_MARK_NUM
          temp_hash['subjects'][ssmap.mark_column]['marks'] = m == ABSENT_MARK_NUM ? "A" : "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['percentage'] = "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['percentile'] = "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['bg'] = "none"
        else
          temp_hash['subjects'][ssmap.mark_column]['marks'] = mark_row.send(ssmap.mark_column.to_sym)
    	  temp_hash['subjects'][ssmap.mark_column]['percentage'] = percentages[ssmap.mark_column]
    	  temp_hash['subjects'][ssmap.mark_column]['percentile'] = percentiles[ssmap.mark_column][mark_row.id]
    	  temp_hash['subjects'][ssmap.mark_column]['bg'] = Grade.get_color_code(percentages[ssmap.mark_column])          
        end

    	temp_hash['subjects'][ssmap.mark_column]['credits'] = ssmap.credits
      end
      temp_hash['total'] = {'marks' => mark_row.total, 'bg' => Grade.get_color_code(mark_row.total) }
      temp_hash['arrears'] = mark_row.get_arrear_subjects_count
      temp_hash['passed'] = mark_row.get_passed_subjects_count
      temp_hash['weighed_total_percentage'] = mark_row.weighed_total_percentage
      temp_hash['weighed_total_percentile'] = weighed_total_percentiles[mark_row.id]
      ret_val << temp_hash
    end
    return ret_val
  end
  
  #batch, department, semester and exam should be valid.
  #For now, we are considering any exam by editing the url.
  #The exam should default to semester final exam.
  def get_batch_marks_with_section
    ret_val = []
    sections = Section.for_department(@department.id).for_batch(@batch.id).all
    sections.each do |section|
      th = {}
      mark_rel = Mark.for_section(section.id).for_semester(@semester.id).for_exam(@exam.id)

      reg_students = section.students.count
      arr_students = ArrearStudent.for_section(section.id).for_semester(@semester.id).count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['section_name'] = section.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val
  end
  
  
  def get_department_marks_with_batch
    ret_val = []
    batches = Batch.all
    batches.each do |batch|
      th = {}
      mark_rel = Mark.search(:section_batch_id_eq => batch.id, :exam_id_eq => @exam.id, :semester_id_eq => @semester.id).result

      reg_students = Student.search(:section_batch_id_eq => batch.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eq => batch.id).result.count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['batch_name'] = batch.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val    	
  end  
  
  def get_batch_marks_with_department
    ret_val = []
    departments = Department.all
    departments.each do |department|
      th = {}
      mark_rel = Mark.search(:section_department_id_eq => department.id, :exam_id_eq => @exam.id, :semester_id_eq => @semester.id).result

      reg_students = Student.search(:section_department_id_eq => department.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eq => department.id).result.count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['batch_name'] = department.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val    	
  end
  
  #Marksheet of a student in a particular semester. Columns:- Exams. Rows:- Subjects.
  #Note that we displaying the marks corresponding to only the exam, not the assignments.
  def one_student_one_semester_all_exams
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
    exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {:display_name => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {:display_name => Exam.find(exam_id).name, :colspan => 1}
    end
    
    #Get the data row wise. One row corresponds to one subject for all the exams. Take a subject
    #get the marks for all the exams. This method is not effective, but as long as it works, it is ok
    #now. Need to see if we can improve this.
    subject_maps.each do |ssmap|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = ssmap.mark_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
        mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id).result.first
        mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
        pass_marks = mc ? mc.pass_marks : 0
        max_marks = mc ? mc.max_marks : 0
        percentages = mark_row.percentages_with_mark_columns
        #Definition in mark.rb => self.subject_percentiles_with_mark_ids(col_name, section_id, semester_id, exam_id)
        percentiles = Mark.subject_percentiles_with_mark_ids(mark_col, @section.id, @semester.id, exam_id)  
        marks_hash[exam_id.to_s] =  { 	
        															:value => mark_row.send(mark_col), :bg => Grade.get_color_code(mark_row.send(mark_col)) , 
        															:max_marks => max_marks,  :pass_marks => pass_marks, 
        															:percentage => percentages[mark_col], :percentile => percentiles[mark_row.id]
    															}
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {:subject_name =>  ssmap.subject.name + sub_type}.merge(marks_hash)
    end
    return {:column_keys => column_keys, :column_headings => column_headings, :table_values => table_values}
  end  
  
  
  #Marksheet of a student in a particular semester for one exam. 
  #Columns:- Exam and assignments for that exam. Rows:- Subjects.
  def one_student_one_semester_one_exam
  	#this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
    table_values = []
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all
    #Get the exam id and assignments of that particular exam. Note that all the assignments are considered as exams.
    #The assignments are going to be yet another row as an exam would be.
    exam_ids = [@exam.id] + @exam.assignments.map {|x| x.id}
    column_keys = ['subject_name'] + exam_ids.map {|x| x.to_s} + ['total_marks', 'percentage']
    column_headings = {}

    #Populate the column_headings and column_sub_headings hash
    column_headings['subject_name'] = {:display_name => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {:display_name => Exam.find(exam_id).name, :colspan => 1}
    end
    column_headings['total_marks'] = {:display_name => "Total", :colspan => 1}
    column_headings['percentage'] = {:display_name => "Percentage", :colspan => 1}
    
    subject_maps.each do |ssmap|
      subject_attended_in_section_ids = []
      subject_attended_in_section_ids << @student.section_id
      subject_attended_in_section_ids +=  ArrearStudent.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :subject_id_eq => ssmap.subject_id).result.select("section_id").map{  |x| x.section_id }
      subject_attended_in_section_ids.each do |cur_sec_id|
        marks_hash = {}
        mark_col = ssmap.mark_column
        tot_val = tot_pass_marks = tot_max_marks = 0
        exam_ids.each do |exam_id|
          mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @student.section_id, :exam_id_eq => exam_id).result.first
          mc = MarkCriteria.search(:semester_id_eq => mark_row.semester_id, :section_id_eq => mark_row.section_id, :exam_id_eq => mark_row.exam_id, :subject_id_eq => ssmap.subject_id).result.first
          pass_marks = mc ? mc.pass_marks : 0
          max_marks = mc ? mc.max_marks : 0
          percentages = mark_row.percentages_with_mark_columns
          percentiles = Mark.subject_percentiles_with_mark_ids(mark_col, mark_row.section_id, mark_row.semester_id, mark_row.exam_id)  
          marks_hash[exam_id.to_s] =  { 	
        															:value => mark_row.send(mark_col), :bg => Grade.get_color_code(mark_row.send(mark_col)) , 
        															:max_marks => max_marks,  :pass_marks => pass_marks, 
        															:percentage => percentages[mark_col], :percentile => percentiles[mark_row.id]
    															}
    	  #Add the value in each iteration to get the sum of the marks of exam and assignments.
          tot_val = tot_val + mark_row.send(mark_col)    															
          tot_pass_marks = tot_pass_marks + pass_marks
          tot_max_marks = tot_max_marks + max_marks
        end
        tot_percentage = tot_val.to_f * 100 / tot_max_marks
        marks_hash['total_marks'] = tot_val
        marks_hash['percentage'] = tot_percentage
        sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
        table_values << {:subject_name =>  ssmap.subject.name + sub_type}.merge(marks_hash)
      end
    end
    return {:column_keys => column_keys, :column_headings => column_headings, :table_values => table_values}
  end    

  def  table_values_hash
    {:value => 0, :bg => '', :percentage => 0, :percentile => 0 }
  end
  
  def column_sub_headings_hash
    {:display_name => '', :max_marks => 100, :pass_marks => 40 }
  end
  
  def column_headings_hash
    {:display_name => '', :colspan => 1}
  end

end
