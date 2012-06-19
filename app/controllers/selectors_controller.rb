class SelectorsController < ApplicationController
  def index
  	#Note that we are not limiting the semesters, or batches or sections
  	#using cancan access control. At this time, it is decided that the design
  	#will be sleek if we do not restrict. In case, there needs to be a restriction,
  	#one can do so with the 'accessible_by(current_ability)' method. 
  	#(Refer the other index actions)
    if params[:required] == 'batch'
      return if params[:semester_id] == ""
      @entities = Batch.all
    elsif params[:required] == 'section'
      return if params[:semester_id] == ""  || params[:batch_id] == ""
      @entities = Batch.find(params[:batch_id]).sections
    elsif params[:required] == 'exam'
      return if params[:semester_id] == ""  || params[:batch_id] == "" || params[:section_id] == ""
      @entities = SecExamMap.for_section(params[:section_id]).for_semester(params[:semester_id]).all.map{|map| map.exam}
    end
  end
  
  def report_selector
  	#Basically we are allowing all batches, departments and semesters to be selected by default.
  	#But a user can select a section only if he has selected a department and a batch.
  	#And, a user can select an exam only if he has selected a semester and section.
  	#According the filters, selected a suitable report will be displayed.
    if params[:required] == 'section'
      return if params[:department_id] == "" || params[:batch_id] == ""
      @entities = Section.for_department(params[:department_id]).for_batch(params[:batch_id]).all
  	elsif params[:required] == 'exam'
  	  return if params[:semester_id] == "" || params[:section_id] == ""
      @entities = SecExamMap.for_semester(params[:semester_id]).for_section(params[:section_id]).all.map{|map| map.exam}
  	elsif params[:required] == 'student'
  	  return if params[:section_id] == ""
      @entities = Section.find(params[:section_id]).students
    end  		    
  end
  
  def students
  	#Search for students whose id_no or name has the query string within it.
  	match = params[:q].downcase
  	#The query parameter will always be in down case. Use the lower() in the query string.
  	@entities = Student.where("lower(name) like ? or lower(id_no) like ?", "%#{match}%",  "%#{match}%").all
  end
end
