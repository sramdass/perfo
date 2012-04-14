class SubjectsController < ApplicationController

  def index
  	@q = Subject.search(params[:q])
    @subjects = @q.result(:distinct => true)
  end

  def new
  	@subject = Subject.new
  end

  def create
    @subject = Subject.new(params[:subject])
    @subject.lab = false if !params[:subject][:lab]
    @subject.institution = Institution.find_by_subdomain(request.subdomain)
    if @subject.save
      flash[:notice] = 'Subject successfully created'
      if params[:create_and_add]
      	redirect_to new_subject_path
      else
        redirect_to subject_path @subject
      end
    else
      render :new
    end
  end
  
  def show
  	@subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])
    @subject.lab = false if !params[:subject][:lab]    
    if @subject.update_attributes(params[:subject])
    	flash[:notice] = 'Subject successfully updated'
      redirect_to subject_path @subject
    else
      render :edit
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end
  
  def destroy
  	Subject.find(params[:id]).destroy
  	redirect_to subjects_path
  end

end
