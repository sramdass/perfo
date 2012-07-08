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
    	
    elsif @section
      @marks = get_section_marks(params)
    end
    	
  end
  
  def get_section_marks(params)
  	ret_val = []
    marks = Mark.for_section(params[:section_id]).for_semester(params[:semester_id]).for_exam(params[:exam_id])
    marks.each do |mark_row|
      temp_hash = {}
      total_credits = 0
      total_percentage=0
      temp_hash['student_name'] = mark_row.student.name
      temp_hash['subjects'] = {}
      percentages = mark_row.percentages_with_mark_columns
      percentiles = {}
      weighed_total_percentiles = Mark.weighed_total_percentiles_with_mark_ids(params[:section_id], params[:semester_id], params[:exam_id])
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
	    percentiles[ssmap.mark_column] = Mark.subject_percentiles_with_mark_ids(ssmap.mark_column, params[:section_id], params[:semester_id], params[:exam_id])
      end      
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
      	temp_hash['subjects'][ssmap.mark_column] = {}
    	temp_hash['subjects'][ssmap.mark_column]['marks'] = mark_row.send(ssmap.mark_column.to_sym)
    	temp_hash['subjects'][ssmap.mark_column]['percentage'] = percentages[ssmap.mark_column]
    	temp_hash['subjects'][ssmap.mark_column]['percentile'] = percentiles[ssmap.mark_column][mark_row.id]
    	temp_hash['subjects'][ssmap.mark_column]['bg'] = Grade.get_color_code(percentages[ssmap.mark_column])
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

end
