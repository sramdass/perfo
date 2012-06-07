class GradesController < ApplicationController
  load_and_authorize_resource
  
  def index
  	@q = Grade.search(params[:q])
    @grades = @q.result(:distinct => true).accessible_by(current_ability)
  end

  def new
  	#@grade = Grade.new
  end

  def create
    #@grade = Grade.new(params[:grade])
    if @grade.save
      flash[:notice] = 'Grade successfully created'
      if params[:create_and_add]
      	redirect_to new_grade_path
      else
        redirect_to grade_path @grade
      end
    else
      render :new
    end
  end
  
  def show
  	#@grade = Grade.find(params[:id])
  end

  def update
    #@grade = Grade.find(params[:id])
    if @grade.update_attributes(params[:grade])
    	flash[:notice] = 'Grade successfully updated'
      redirect_to grade_path @grade
    else
      render :edit
    end
  end

  def edit
    #@grade = Grade.find(params[:id])
  end
  
  def destroy
    #@grade = Grade.find(params[:id])
  	@grade.destroy
  	redirect_to grades_path
  end

end
