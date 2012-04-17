class SchoolTypesController < ApplicationController
  
  def new
  	@school_type = SchoolType.new
  end

  def index
    @school_types = SchoolType.all
  end
  
  def create
    @school_type = SchoolType.new(params[:school_type])
    if @school_type.save
      flash[:notice] = 'SchoolType successfully created'
      if params[:create_and_add]
      	redirect_to new_school_type_path
      else
        redirect_to school_type_path @school_type
      end
    else
      render :new
    end
  end
  
  def show
  	@school_type = SchoolType.find(params[:id])
  end
  
  def destroy
  	@school_type = SchoolType.find(params[:id])
  	@school_type.destroy
  	redirect_to school_types_path
  end

  def update
    @school_type = SchoolType.find(params[:id])
      if @school_type.update_attributes(params[:school_type])
      	flash[:notice] = 'SchoolType successfully updated'
        redirect_to @school_type
      else
        render :edit
      end
  end

  def edit
    @school_type = SchoolType.find(params[:id])
    @title = "Edit SchoolType"
  end
end
