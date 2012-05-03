class SelectorsController < ApplicationController
  def index
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
end
