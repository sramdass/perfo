class SemestersController < ApplicationController
  load_and_authorize_resource
  def index
  	@q = Semester.search(params[:q])
    @semesters = @q.result(:distinct => true).accessible_by(current_ability)
  end

  def new
  	#@semester = Semester.new
  end

  def create
    #@semester = Semester.new(params[:semester])
    @semester.institution = Institution.find_by_subdomain(request.subdomain)
    if @semester.save
      flash[:notice] = 'Semester successfully created'
      if params[:create_and_add]
      	redirect_to new_semester_path
      else
        redirect_to semester_path @semester
      end
    else
      render :new
    end
  end
  
  def show
  	#@semester = Semester.find(params[:id])
  end

  def update
    #@semester = Semester.find(params[:id])
    if @semester.update_attributes(params[:semester])
    	flash[:notice] = 'Semester successfully updated'
      redirect_to semester_path @semester
    else
      render :edit
    end
  end

  def edit
    #@semester = Semester.find(params[:id])
  end
  
  def destroy
  	#@semester = Semester.find(params[:id])
  	@semester.destroy
  	redirect_to semesters_path
  end

end
