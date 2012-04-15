class FacultiesController < ApplicationController

  def index
  	@q = Faculty.search(params[:q])
    @faculties = @q.result(:distinct => true)
  end

  def new
  	@faculty = Faculty.new
  	#@faculty.contact.build
  	@faculty.build_contact
  end

  def create
    @faculty = Faculty.new(params[:faculty])
    if @faculty.save
      flash[:notice] = 'Faculty successfully created'
      if params[:create_and_add]
      	redirect_to new_faculty_path
      else
        redirect_to faculty_path @faculty
      end
    else
      render :new
    end
  end
  
  def show
  	@faculty = Faculty.find(params[:id])
  end

  def update
    @faculty = Faculty.find(params[:id])
    if @faculty.update_attributes(params[:faculty])
      flash[:notice] = 'Faculty successfully updated'
      redirect_to faculty_path @faculty
    else
      render :edit
    end
  end

  def edit
    @faculty = Faculty.find(params[:id])
  end
  
  def destroy
  	Faculty.find(params[:id]).destroy
  	redirect_to faculties_path
  end

end
