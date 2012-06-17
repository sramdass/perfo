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
  	#But a user can select a section only if he has selected a department or a batch or both.
  	#And, a user can select an exam only if he has selected a semester or section or both.
  	#According the filters, selected a suitable report will be displayed.
    if params[:required] == 'section'
      return if params[:department_id] == "" || params[:batch_id] == ""
      sections_rel = Section
  	  sections_rel = sections_rel.for_department(params[:department_id]) if params[:department_id] != ""
  	  sections_rel = sections_rel.for_batch(params[:batch_id]) if params[:batch_id] != ""
  	  @entities = sections_rel.all
  	elsif params[:required] == 'exam'
  	  return if params[:semester_id] == "" && params[:section_id] == ""
      semaps_rel = SecExamMap
  	  semaps_rel = semaps_rel.for_semester(params[:semester_id]) if params[:semester_id] != ""
  	  semaps_rel = semaps_rel.for_section(params[:section_id]) if params[:section_id] != ""
  	  @entities = semaps_rel.all.map{|map| map.exam}
    end  		
  end
  
  def students
  	#Search for students whose id_no or name has the query string within it.
  	match = params[:q].downcase
  	#The query parameter will always be in down case. Use the lower() in the query string.
  	@entities = Student.where("lower(name) like ? or lower(id_no) like ?", "%#{match}%",  "%#{match}%").all
  end
end
