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
      temp_hash[:student_name] = mark_row.student.name
      temp_hash[:subjects] = {}
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
      	temp_hash[:subjects][ssmap.mark_column.to_sym] = {}
    	temp_hash[:subjects][ssmap.mark_column.to_sym][:marks] = mark_row.send(ssmap.mark_column.to_sym)
    	temp_hash[:subjects][ssmap.mark_column.to_sym][:percentage] = -100
    	temp_hash[:subjects][ssmap.mark_column.to_sym][:percentile] = -100
    	temp_hash[:subjects][ssmap.mark_column.to_sym][:bg] = 'green'
      end
      temp_hash[:total] = {:marks => mark_row.total, :bg => 'blue' }
      temp_hash[:arrears] = mark_row.arrears_count
      temp_hash[:passed] = -1
      temp_hash[:total_percentage] = -2
      temp_hash[:total_percentile] = -3
      ret_val << temp_hash
    end
    return ret_val
  end

end
