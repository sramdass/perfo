class DepartmentsController < ApplicationController

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
    @departments = Department.all
  end

end
