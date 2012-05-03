class DepartmentsController < ApplicationController
before_filter :check_semester, :only => [:hods]
  def index
  	@q = Department.search(params[:q])
    @departments = @q.result(:distinct => true)
  end

  def new
  	@department = Department.new
  end

  def create
    @department = Department.new(params[:department])
    @department.institution = Institution.find_by_subdomain(request.subdomain)
    if @department.save
      flash[:notice] = 'Department successfully created'
      if params[:create_and_add]
      	redirect_to new_department_path
      else
        redirect_to department_path @department
      end
    else
      render :new
    end
  end
  
  def show
  	@department = Department.find(params[:id])
  end

  def update
    @department = Department.find(params[:id])
    if @department.update_attributes(params[:department])
    	flash[:notice] = 'Department successfully updated'
      redirect_to department_path @department
    else
      render :edit
    end
  end

  def edit
    @department = Department.find(params[:id])
  end
  
  def destroy
  	Department.find(params[:id]).destroy
  	redirect_to departments_path
  end
  
  def hods
  	@semesters = Semester.all
    @departments = Department.all
    @faculties = Faculty.all
    respond_to do |format|
      format.html 
      format.js
    end        
  end
  
  def update_hods
  	@semester = Semester.find(params[:semester_id])
  	@semester.hods.destroy_all
  	@section.sec_sub_maps.for_semester(params[:semester_id]).each do |map|
  	  sub_id = map.subject_id
  	  map.attributes = 	{ :subject_id => sub_id, :faculty_id => params[:faculty]["#{sub_id}"] }
  	  ssmaps << map
    end			  	
    if @section.valid? && ssmaps.all?(&:valid?)
      @section.save!
      ssmaps.each(&:save!)
      redirect_to(faculties_sections_path(:section_id => params[:id], :semester_id => params[:semester_id]),  :notice => 'Faculties successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Faculties'
      #We need faculties to re-render
      @faculties = Faculty.all  	
      render :faculties
    end  	  	
  end
  
  private
  
  def check_semester
    @semester = Semester.find(params[:semester_id]) if params[:semester_id]
  end  

end
