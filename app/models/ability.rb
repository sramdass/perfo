class Ability
  include CanCan::Ability
  
  def initialize(profile)
	@profile = profile
	#Without a valid profile, no one can do anything.
	if !@profile
	  return
	end
	#---------TEMPORARY--------------#
	can :manage, :all
	return

	#---------TEMPORARY--------------#
	if @profile.user.id_no == ENV['SUPERUSER']
	  can :manage, :all
	  return
    end	
	@user_type = @profile.user_type
	#All the aliases come here
	#All the create, update and destroy actions should have read permissions. Include them in the aliases itself
	alias_action :new, :read, :to => :create
	alias_action :edit, :read,:to => :update
	@profile.roles.each do |role|
	  Resource.all.each do |res|
	    res.resource_actions.each do |ra|
	      if role.has_privilege?(res.id, ra.code)
	        send("#{res.name.downcase}_#{ra.name}") # This will be like --> faculty_section_read
          end
	    end
	  end
	end
  end #end of def initialize(profile)

#Institution
  def institution_read
    can :read, Institution
  end
  
  def institution_edit
  	can :update, Institution
  end
    
  def institution_create
    can :create, Institution
  end

#Exams
  def exam_read
    can :read, Exam
  end
  
  def exam_edit
  	can :update, Exam
  end
    
  def exam_create
    can :create, Exam
  end
  
  def exam_destroy
  	can :destroy, Exam
  end
  
#Batches
  def batch_read
    can :read, Batch
  end
  
  def batch_edit
  	can :update, Batch
  end
    
  def batch_create
    can :create, Batch
  end
  
  def batch_destroy
  	can :destroy, Batch
  end
  
#Departments

  def department_read
    can :read, Department
  end
  
  def department_edit
  	can :update, Department
  end
    
  def department_create
    can :create, Department
  end
  
  def department_destroy
  	can :destroy, Department
  end
  
  def department_update_hods
    can :hods, Department
    can :update_hods, Department
  end
  
#Sections

  def section_read
    can :read, Section
  end
  
  def section_edit
  	can :update, Section
  end
    
  def section_create
    can :create, Section
  end
  
  def section_destroy
  	can :destroy, Section
  end
  
  def section_update_subjects
    can :subjects, Section
    can :update_subjects, Section
  end  
  
  def section_update_faculties
    can :faculties, Section
    can :update_faculties, Section  	
  end
  
  def section_update_exams
    can :exams, Section
    can :update_exams, Section  	
  end
  
#Semesters
  def semester_read
    can :read, Semester
  end
  
  def semester_edit
  	can :update, Semester
  end
    
  def semester_create
    can :create, Semester
  end
  
  def semester_destroy
  	can :destroy, Semester
  end  
  
#Subjects
  def subject_read
    can :read, Subject
  end
  
  def subject_edit
  	can :update, Subject
  end
    
  def subject_create
    can :create, Subject
  end
  
  def subject_destroy
  	can :destroy, Subject
  end  
  
#Students
  def student_read
    can :read, Student
  end
  
  def student_edit
  	can :update, Student
  end
    
  def student_create
    can :create, Student
  end
  
  def student_destroy
  	can :destroy, Student
  end
  
  def student_self_read
  	if @profile.user_type.eql?("Student")
  	  can :read, Student, :id => @profile.user_id
  	end  	
  end
  
#Faculties
  def faculty_read
    can :read, Faculty
  end
  
  def faculty_edit
  	can :update, Faculty
  end
    
  def faculty_create
    can :create, Faculty
  end
  
  def faculty_destroy
  	can :destroy, Faculty
  end      
  
  def faculty_self_read
  	if @profile.user_type.eql?("Faculty")
  	  can :read, Faculty, :id => @profile.user_id
  	end  	
  end
  
#UserProfiles
#Note: the module name should be userprofile_*, not user_profile_*
  def userprofile_read
    can :read, UserProfile
  end
  
  def userprofile_edit
  	can :update, UserProfile
  end
 
  def userprofile_destroy
  	can :destroy, UserProfile
  end
  
  def userprofile_self_read
  	can :read, UserProfile, :id => @profile.id
  end 
  
#SchoolTypes
  def schooltype_read
    can :read, SchoolType
  end
  
  def schooltype_edit
  	can :update, SchoolType
  end
    
  def schooltype_create
    can :create, SchoolType
  end
  
  def schooltype_destroy
  	can :destroy, SchoolType
  end  
  
#BloodGroups
  def bloodgroup_read
    can :read, BloodGroup
  end
  
  def bloodgroup_edit
  	can :update, BloodGroup
  end
    
  def bloodgroup_create
    can :create, BloodGroup
  end
  
  def bloodgroup_destroy
  	can :destroy, BloodGroup
  end  

end
