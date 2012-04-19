class SectionsController < ApplicationController

  def index
  	@q = Section.search(params[:q])
    @sections = @q.result(:distinct => true)
  end

  def new
  	@section = Section.new
  end

  def create
    @section = Section.new(params[:section])
    if @section.save
      flash[:notice] = 'Section successfully created'
      redirect_to section_path @section
    else
      render :new
    end
  end
  
  def show
  	@section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    #Do not allow the batch or department for this section to be changed.
    #If they need to change the section or department, they have to create 
    #a new section resource.
    if params[:section][:department_id] != @section.department_id.to_s
      flash[:error] = "Cannot change the department. You may need to delete this section and create a new one."
      render :edit
      return
    end
    if params[:section][:batch_id] != @section.batch_id.to_s
      flash[:error] = "Cannot change the batch. You may need to delete this section and create a new one."
      render :edit
      return
    end    
    if @section.update_attributes(params[:section])
      flash[:notice] = 'Section successfully updated'
      redirect_to section_path @section
    else
      render :edit
    end
  end

  def edit
    @section = Section.find(params[:id])
  end
  
  def destroy
  	Section.find(params[:id]).destroy
  	redirect_to sections_path
  end

end
