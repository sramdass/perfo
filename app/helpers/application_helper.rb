module ApplicationHelper
  def labeled_form_for(object, options = {}, &block)
    options[:builder] = LabeledFormBuilder
    form_for(object, options, &block)
  end	
  
  #give the links for the semi_index partial
  def edit_link(obj)
  	case obj.class.to_s
  	  when  "Tenant"
  	    edit_tenant_path(obj)
  	  when  "Semester"
  	    edit_semester_path(obj)
  	  when  "Department"
  	    edit_department_path(obj)
  	  when  "Subject"
  	    edit_subject_path(obj)  	    
  	  when  "Faculty"
  	    edit_faculty_path(obj)
  	  when  "Exam"
  	    edit_exam_path(obj)  	      	      	    
  	 when nil
  	    nil
    end
  end
  
  def index_link(obj)
  	case obj.class.to_s
  	  when  "Tenant"
  	    tenants_path
  	  when  "Semester"
  	    semesters_path  
  	  when  "Department"
  	    departments_path
  	  when  "Subject"
  	    subjects_path  
  	  when  "Faculty"
  	    faculties_path
  	  when  "Exam"
  	    exams_path    	      	    
  	 when nil
  	    nil
    end
  end  

end
