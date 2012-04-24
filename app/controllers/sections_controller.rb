class SectionsController < ApplicationController
before_filter :check_semester, :only => [:subjects, :update_subjects, :faculties, :update_faculties, :exams, :update_exams]

  def index
  	@q = Section.search(params[:q])
    @sections = @q.result(:distinct => true)
  end

  def new
  	@section = Section.new
  end

  def create
    @section = Section.new(params[:section])
    if @section.save
      flash[:notice] = 'Section successfully created'
      redirect_to section_path @section
    else
      render :new
    end
  end
  
  def show
  	@section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    #Do not allow the batch or department for this section to be changed.
    #If they need to change the section or department, they have to create 
    #a new section resource.
    if params[:section][:department_id] != @section.department_id.to_s
      flash[:error] = "Cannot change the department. You may need to delete this section and create a new one."
      render :edit
      return
    end
    if params[:section][:batch_id] != @section.batch_id.to_s
      flash[:error] = "Cannot change the batch. You may need to delete this section and create a new one."
      render :edit
      return
    end    
    if @section.update_attributes(params[:section])
      flash[:notice] = 'Section successfully updated'
      redirect_to section_path @section
    else
      render :edit
    end
  end

  def edit
    @section = Section.find(params[:id])
  end
  
  def destroy
  	Section.find(params[:id]).destroy
  	redirect_to sections_path
  end
  
#For subjects, faculties, exams and update version of these modules,
#we need the semester id. If the semester_id is not present, we error
#out. This is done using the before_filter
  def subjects
    @section = Section.find(params[:id])
    @subjects = Subject.all
  end
  
  def update_subjects
    @section = Section.find(params[:id])
    SecSubMap.for_section(@section.id).for_semester(params[:semester_id]).destroy_all
    params[:section][:subject_ids].each do |sub_id|
      @section.sec_sub_maps.build({:subject_id => sub_id, :semester_id => params[:semester_id]})
    end
    if @section.valid? && @section.sec_sub_maps.all?(&:valid?)
      @section.save!
      @section.sec_sub_maps.each(&:save!)
      redirect_to(@section,  :notice => 'Section was successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Subjects'
      render :subjects
    end  	
  end
  
  def faculties
    @section = Section.find(params[:id])
    @faculties = Faculty.all  	
  end
  
  def update_faculties
  	#We have to explicity track the ssmaps that are modified and save them. We are using 
  	# "@section.sec_sub_maps.for_semester(params[:semester_id]).each do |map|" for the loop.
  	#When the naming scope is used - @section.sec_sub_maps.each(&:save!) is not working.
  	ssmaps = Array.new
  	@section = Section.find(params[:id])
  	@section.sec_sub_maps.for_semester(params[:semester_id]).each do |map|
  	  sub_id = map.subject_id
  	  map.attributes = 	{ :subject_id => sub_id, :faculty_id => params[:faculty]["#{sub_id}"] }
  	  ssmaps << map
    end			  	
    if @section.valid? && ssmaps.all?(&:valid?)
      @section.save!
      ssmaps.each(&:save!)
      redirect_to(@section,  :notice => 'Section was successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Subjects'
      render :subjects
    end  	
  end
  
  def exams
    @section = Section.find(params[:id])
    @exams = Exam.all  	  	
  end
  
  def update_exams
    @section = Section.find(params[:id])
    SecExamMap.for_section(@section.id).for_semester(params[:semester_id]).destroy_all
    params[:section][:exam_ids].each do |exam_id|
      @section.sec_exam_maps.build({:exam_id => exam_id, :semester_id => params[:semester_id]})
    end
    if @section.valid? && @section.sec_sub_maps.all?(&:valid?)
      @section.save!
      @section.sec_sub_maps.each(&:save!)
      redirect_to(@section,  :notice => 'Section was successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Subjects'
      render :subjects
    end  	  	
  end
  
  private
  
  def check_semester
  	#If the semester id is not present or corresponds to an invalid semester, display an error.
  	#TODO: Redirect to the page where the user came from
  	if !params[:semester_id] || !Semester.find(params[:semester_id])
  	  @section = Section.find(params[:id])
  	  flash[:error] = "Invalid Semester"
  	  redirect_to @section
  	end
  end

end
