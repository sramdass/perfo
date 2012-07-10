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
    
    if @student
    
    #we do not need the exam here. the exam should default to semester final exam
    elsif @department && @semester && @exam
      @marks = get_department_marks_with_batch    
    elsif @batch && @semester && @exam
      @marks = get_batch_marks_with_department
    elsif @batch && @department && @exam && @semester
      @marks = get_batch_marks_with_section
    elsif @batch

    elsif @section
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
      mark_rel = Mark.search(:section_batch_id_eql => batch.id, :exam_id_eql => @exam.id, :semester_id_eql => @semester.id).result

      reg_students = Student.search(:section_batch_id_eql => batch.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eql => batch.id).result.count
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
      mark_rel = Mark.search(:section_department_id_eql => department.id, :exam_id_eql => @exam.id, :semester_id_eql => @semester.id).result

      reg_students = Student.search(:section_department_id_eql => department.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eql => department.id).result.count
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

end
