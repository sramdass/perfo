class DepartmentsController < ApplicationController
#For now, the code in check_semester is moved into the hods action
#before_filter :check_semester, :only => [:hods]
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
  	@semester = Semester.find(params[:semester_id]) if params[:semester_id]
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
  	hods = Array.new
  	params[:faculty].each do |dept_id, faculty_id|
  	  #This will have all the departments, but not necessarily a faculty for the depts. So skip when there is not faculty_id
  	  @semester.hods.build(:faculty_id => faculty_id, :department_id => dept_id) if faculty_id
  	end
    if @semester.hods.all?(&:valid?)
      @semester.hods.each(&:save!)
      redirect_to(hods_departments_path(:semester_id => params[:semester_id]),  :notice => 'HODs successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Faculties'
      #We need these resources to re-render
  	  @semesters = Semester.all
      @departments = Department.all
      @faculties = Faculty.all
      render :hods
    end  	  	
  end
  
  private
  
  def check_semester
    @semester = Semester.find(params[:semester_id]) if params[:semester_id]
  end  

end
