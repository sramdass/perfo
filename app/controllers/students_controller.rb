class StudentsController < ApplicationController

  def index
  	if params[:section_id]
  	  if params[:q]
  	    params[:q].merge(:section_id_eq => params[:section_id])
  	  else
  	    params[:q] = {:section_id_eq => params[:section_id]}
  	  end
  	end
  	@q = Student.search(params[:q])
    @students = @q.result(:distinct => true)
  end

  def new
  	@student = Student.new
  	@student.build_contact
  	 if params[:section_id]
  	  @student.section_id=params[:section_id]
  	end
  end

  def create
    @student = Student.new(params[:student])
    if @student.save
      flash[:notice] = 'Student successfully created'
      if params[:create_and_add_students]
      	redirect_to new_student_path(:section_id => params[:student][:section_id])
      else
        redirect_to student_path @student
      end
    else
      render :new
    end
  end
  
  def show
  	@student = Student.find(params[:id])
  end

  def update
    @student = Student.find(params[:id])
    #If they need to change the section, they have to create 
    #a new student resource.
    if params[:student][:section_id] != @student.section_id.to_s
      flash[:error] = "Cannot change the section. You may need to delete this student and create a new one."
      render :edit
      return
    end    
    if @student.update_attributes(params[:student])
      flash[:notice] = 'Student successfully updated'
      redirect_to student_path @student
    else
      render :edit
    end
  end

  def edit
    @student = Student.find(params[:id])
  end
  
  def destroy
  	Student.find(params[:id]).destroy
  	redirect_to students_path
  end

end
