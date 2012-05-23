class ExamsController < ApplicationController
  load_and_authorize_resource
  
  def index
  	@q = Exam.search(params[:q])
    @exams = @q.result(:distinct => true)
  end

  def new
  	@exam = Exam.new
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.institution = Institution.find_by_subdomain(request.subdomain)
    if @exam.save
      flash[:notice] = 'Exam successfully created'
      if params[:create_and_add]
      	redirect_to new_exam_path
      else
        redirect_to exam_path @exam
      end
    else
      render :new
    end
  end
  
  def show
  	@exam = Exam.find(params[:id])
  end

  def update
    @exam = Exam.find(params[:id])
    if @exam.update_attributes(params[:exam])
    	flash[:notice] = 'Exam successfully updated'
      redirect_to exam_path @exam
    else
      render :edit
    end
  end

  def edit
    @exam = Exam.find(params[:id])
  end
  
  def destroy
  	Exam.find(params[:id]).destroy
  	redirect_to exams_path
  end

end
