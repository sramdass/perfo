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
    #We cannot use @section.attributes = params[:section] with the nested_attributes feature, because the subject_ids can
    #be duplicate as the primiary key is not section_id + subject_id, but section_id + subject_id + semester_id combo. Important!
    #We are removing all the rows and add the new ones even if a subject that is already present is coming in. This is the easiest way.
    #For the subjects, that are already there,we MUST maintain the same mark_column values. So, we iterate the subject_ids that 
    #are coming in, and if a subject_id is already present in the db, we use the same mark_column in the new row we are creating.
    #For the new subject_ids (that are not already in the database), we can use any mark_column values.
    
    #There is a lot of detour in the logic, becuase we cannot save only a part of the sec_sub_maps, and until we do not store them 
    #we do not know what are the mark_colums we have use. That is where taken_mark_cols[] comes into picture.
    
    subject_ids = params[:section][:subject_ids] || []
    new_subject_ids = [] #to track the subject_ids that are not already present.
    taken_mark_cols = [] #Intermediate bucket to store all the used mark_cols.
    subject_ids.each do |sub_id|
      mark_col = existing_mark_column(sub_id, @semester.id)
      #if mark_col is not nil, it means that this subject_id is already present in the database.
      if mark_col
      	#mark this mark_col as a used one.
        taken_mark_cols << mark_col
       @section.sec_sub_maps.build({:subject_id => sub_id, :semester_id => @semester.id, :mark_column => mark_col})
      else
      	#store the subject_ids for which the entries are not created yet.
      	new_subject_ids << sub_id
      end
    end
    
    SecSubMap.for_section(@section.id).for_semester(@semester.id).destroy_all
    #get all the mark_column values that can be used for the new sec_sub_map entires we are going to create now.
    new_mark_cols = new_mark_columns(taken_mark_cols)
    
    new_subject_ids.each do |sub_id|
      #take the first mark_column value and use it for the sec_sub_map created here.
      t = new_mark_cols.shift
      #The marks of column 't' should be set to default
      @section.sec_sub_maps.build({:subject_id => sub_id, :semester_id => @semester.id, :mark_column => t})
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
  #this is a before_filter and is used to load the required resources.  
  def check_semester
    @semester = Semester.find(params[:semester_id]) if params[:semester_id]
    @batch = Batch.find(params[:batch_id]) if params[:batch_id] 
  	@section = Section.find(params[:section_id]) if params[:section_id] 
  end

  #Module to return the mark_column value if there is already a sec_sub_map existing for the given subject_id +
  #semester_id + @section.id combination. 
  #To the caller:- If the returned value is nil, we do not have that entry, and we have to create a new one.
  def existing_mark_column(subject_id, semester_id)
    temp_row = SecSubMap.for_subject(subject_id).for_semester(semester_id).for_section(@section.id).first
    if temp_row && temp_row.mark_column	
      return temp_row.mark_column
    end  	
  end
  
  #Module takes a list of used mark_columns for any section_id + subject_id + semester_id combination and returns
  #the list of mark_column values that can be used for the new sec_sub_maps that are created.  	
  def new_mark_columns(taken_mark_cols)
    cols = (1..MARKS_SUBJECTS_COUNT).to_a
    cols.each do |col|
      cols.delete_if {|x| taken_mark_cols.include?("sub#{x}") }
    end	
    cols.map! {|x| "sub#{x}" }		
    return cols
  end

end
