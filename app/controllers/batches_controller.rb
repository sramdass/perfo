class BatchesController < ApplicationController
  load_and_authorize_resource
  def index
  	@q = Batch.search(params[:q])
    @batches = @q.result(:distinct => true).accessible_by(current_ability)
  end

  def new
  	#@batch = Batch.new
  end

  def create
    #@batch = Batch.new(params[:batch])
    @batch.institution = Institution.find_by_subdomain(request.subdomain)
    if @batch.save
      flash[:notice] = 'Batch successfully created'
      if params[:create_and_add]
      	redirect_to new_batch_path
      else
        redirect_to batch_path @batch
      end
    else
      render :new
    end
  end
  
  def show
  	#@batch = Batch.find(params[:id])
  end

  def update
    #@batch = Batch.find(params[:id])
    if @batch.update_attributes(params[:batch])
    	flash[:notice] = 'Batch successfully updated'
      redirect_to batch_path @batch
    else
      render :edit
    end
  end

  def edit
    #@batch = Batch.find(params[:id])
  end
  
  def destroy
  	#@batch = Batch.find(params[:id])
  	@batch.destroy
  	redirect_to batches_path
  end

end
