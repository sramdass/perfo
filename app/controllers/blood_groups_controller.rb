class BloodGroupsController < ApplicationController
  load_and_authorize_resource
  def new
  	#@blood_group = BloodGroup.new
  end

  def index
    #@blood_groups = BloodGroup.all
  end
  
  def create
    #@blood_group = BloodGroup.new(params[:blood_group])
    if @blood_group.save
      flash[:notice] = 'Blood Group successfully created'
      if params[:create_and_add]
      	redirect_to new_blood_group_path
      else
        redirect_to blood_group_path @blood_group
      end
    else
      render :new
    end
  end
  
  def show
  	#@blood_group = BloodGroup.find(params[:id])
  end
  
  def destroy
  	#@blood_group = BloodGroup.find(params[:id])
  	@blood_group.destroy
  	redirect_to blood_groups_path
  end

  def update
    #@blood_group = BloodGroup.find(params[:id])
      if @blood_group.update_attributes(params[:blood_group])
      	flash[:notice] = 'Blood Group successfully updated'
        redirect_to @blood_group
      else
        render :edit
      end
  end

  def edit
    #@blood_group = BloodGroup.find(params[:id])
  end
end
