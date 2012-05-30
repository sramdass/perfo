class SectionsController < ApplicationController
  before_filter :check_semester, :only => [:subjects, :update_subjects, :faculties, :update_faculties,  :exams, :update_exams, :arrear_students, :update_arrear_students]
  load_and_authorize_resource
  
  def index
  	@q = Section.search(params[:q])
    @sections = @q.result(:distinct => true).accessible_by(current_ability)
  end

  def new
  	#@section = Section.new
  end

  def create
    #@section = Section.new(params[:section])
    if @section.save
      flash[:notice] = 'Section successfully created'
      redirect_to section_path @section
    else
      render :new
    end
  end
  
  def show
  	#@section = Section.find(params[:id])
  end

  def update
    #@section = Section.find(params[:id])
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
    #@section = Section.find(params[:id])
  end
  
  def destroy
  	#@section = Section.find(params[:id])
  	@section.destroy
  	redirect_to sections_path
  end
  
#For subjects, faculties, exams and update version of these modules,
#we need the semester id. If the semester_id is not present, we error
#out. This is done using the before_filter

#Note that here we are not limiting the list of subjects or faculties or
#exams that are listed to choose from. If we restrict, there may be scenarios
#where a faculty had been selected for a subject and the current user may
#not have read access to that faculty. In this case, it will display a 'None' in the
#faculty field, and clicking the update action will result in undesirable consequences.
#In case there is a need for restriction, look at the commented lines.
  def subjects
    @subjects = Subject.all
    #@subjects = Subject.accessible_by(current_ability)
    respond_to do |format|
      format.html 
      format.js
    end    
  end
  
  def update_subjects
    #@section = Section.find(params[:id])
    SecSubMap.for_section(@section.id).for_semester(@semester.id).destroy_all
    params[:section][:subject_ids].each do |sub_id|
      @section.sec_sub_maps.build({:subject_id => sub_id, :semester_id => @semester.id})
    end
    if @section.valid? && @section.sec_sub_maps.all?(&:valid?)
      @section.save!
      @section.sec_sub_maps.each(&:save!)
      redirect_to(subjects_sections_path(:section_id => params[:id], :semester_id => @semester.id),  :notice => 'Section was successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Subjects'
      #It is intentional that we are using a redirect here (rather than a render). We are getting some errors with the render.
      #redirect seems to be a cleaner solution in this ajax scenario.
      redirect_to(subjects_sections_path(:section_id => params[:id], :semester_id => @semester.id))
    end  	
  end
  
  def faculties
    @faculties = Faculty.all  	
    #@faculties = Faculty.accessible_by(current_ability)
    respond_to do |format|
      format.html 
      format.js
    end       
  end
  
  def update_faculties
  	#@section = Section.find(params[:id])
  	#We have to explicity track the ssmaps that are modified and save them. We are using 
  	# "@section.sec_sub_maps.for_semester(@semester.id).each do |map|" for the loop.
  	#When the naming scope is used - @section.sec_sub_maps.each(&:save!) is not working.
  	ssmaps = Array.new
  	@section = Section.find(params[:id])
  	@section.sec_sub_maps.for_semester(@semester.id).each do |map|
  	  sub_id = map.subject_id
  	  map.attributes = 	{ :subject_id => sub_id, :faculty_id => params[:faculty]["#{sub_id}"] }
  	  ssmaps << map
    end			  	
    if @section.valid? && ssmaps.all?(&:valid?)
      @section.save!
      ssmaps.each(&:save!)
      redirect_to(faculties_sections_path(:section_id => params[:id], :semester_id => @semester.id),  :notice => 'Faculties successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Faculties'
      #It is intentional that we are using a redirect here (rather than a render). We are getting some errors with the render.
      #redirect seems to be a cleaner solution in this ajax scenario.
      redirect_to(faculties_sections_path(:section_id => params[:id], :semester_id => @semester.id))
    end  	
  end
  
  def exams
    @exams = Exam.all  	  	
    #@exams = Exam.accessible_by(current_ability)
    respond_to do |format|
      format.html 
      format.js
    end         
  end
  
  def update_exams
    #@section = Section.find(params[:id])
    SecExamMap.for_section(@section.id).for_semester(@semester.id).destroy_all
    params[:section][:exam_ids].each do |exam_id|
      @section.sec_exam_maps.build({:exam_id => exam_id, :semester_id => @semester.id})
    end
    if @section.valid? && @section.sec_sub_maps.all?(&:valid?)
      @section.save!
      @section.sec_sub_maps.each(&:save!)
      redirect_to(exams_sections_path(:section_id => params[:id], :semester_id => @semester.id),  :notice => 'Exams successfully updated.')
    else
      flash[:error] = 'Error! Cannot Assign Exams'
      #It is intentional that we are using a redirect here (rather than a render). We are getting some errors with the render.
      #redirect seems to be a cleaner solution in this ajax scenario.      
      redirect_to(exams_sections_path(:section_id => params[:id], :semester_id => @semester.id))
    end  	  	
  end
  
  def arrear_students
    respond_to do |format|
      format.html 
      format.js
    end       
  end
  
  def update_arrear_students
  	arr_stus = Array.new
  	@section = Section.find(params[:id])
  	ArrearStudent.for_section(@section.id).for_semester(@semester.id).destroy_all
  	@section.sec_sub_maps.for_semester(@semester.id).each do |map|
  	  sub_id = map.subject_id
  	  student_ids = []
  	  #The parameter list will be like - {"1"=>["1,4,5"], "2"=>["2,3"], "3"=>[""], "6"=>[""]}
  	  #Note that student_ids will be provided as a single string with the ids separated by commas (tokeninput plugin).
  	  #Also, when we check or split the values (student_ids), we need to use the array_element.first becuase we cannot 
  	  #split the array, but an element  of the array
  	  student_ids = params[:arrear_students]["#{sub_id}"].first.split(',') if !params[:arrear_students]["#{sub_id}"].first.blank?
  	  student_ids.each do |stu_id|
  	    arr_stus << ArrearStudent.new(:student_id => stu_id, :subject_id => sub_id, :semester_id => @semester.id, :section_id => @section.id)
  	  end
    end			  	
    if @section.valid? && arr_stus.all?(&:valid?)
      @section.save!
      arr_stus.each(&:save!)
      redirect_to(arrear_students_sections_path(:section_id => params[:id], :semester_id => @semester.id), :notice => 'Students successfully assigned')
    else
      flash[:error] = 'Error! Cannot Assign Students'
      #It is intentional that we are using a redirect here (rather than a render). We are getting some errors with the render.
      #redirect seems to be a cleaner solution in this ajax scenario.      
      redirect_to(arrear_students_sections_path(:section_id => params[:id], :semester_id => @semester.id))
    end  	
  end  
  
  private
  
  def check_semester
    @semester = Semester.find(params[:semester_id]) if params[:semester_id]
    @batch = Batch.find(params[:batch_id]) if params[:batch_id] 
  	@section = Section.find(params[:section_id]) if params[:section_id] 
  end

end
