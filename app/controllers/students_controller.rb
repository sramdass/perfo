class StudentsController < ApplicationController

  def index
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
      	redirect_to new_student_path
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
    #Do not allow the batch or department for this student to be changed.
    #If they need to change the student or department, they have to create 
    #a new student resource.
    if params[:student][:department_id] != @student.department_id.to_s
      flash[:error] = "Cannot change the department. You may need to delete this student and create a new one."
      render :edit
      return
    end
    if params[:student][:batch_id] != @student.batch_id.to_s
      flash[:error] = "Cannot change the batch. You may need to delete this student and create a new one."
      render :edit
      return
    end    
    if @student.update_attributes(params[:student])
      flash[:notice] = 'Student successfully updated'
      if params[:update_and_edit_students]
      	redirect_to new_student_path
      else
        redirect_to student_path @student
      end      
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
