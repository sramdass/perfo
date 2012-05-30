class SelectorsController < ApplicationController
  def index
  	#Note that we are not limiting the semesters, or batches or sections
  	#using cancan access control. At this time, it is decided that the design
  	#will be sleek if we do not restrict. In case, there needs to be a restriction,
  	#one can do so with the 'accessible_by(current_ability)' method. 
  	#(Refer the other index actions)
  	@semesters = Semester.all
  	if params[:base] #Control to see if this is a json request
  	  base_entity = params[:base].camelize.constantize
  	  if params[:required] == 'batch'
  	    @entities = Batch.all
  	  end
  	  if params[:required] == 'section'
  	    @entities = base_entity.find(params[:base_id]).sections
  	  end  	
  	end
  end
  
  def students
  	#Search for students whose id_no or name has the query string within it.
  	match = params[:q].downcase
  	#The query parameter will always be in down case. Use the lower() in the query string.
  	@entities = Student.where("lower(name) like ? or lower(id_no) like ?", "%#{match}%",  "%#{match}%").all
  end
end
