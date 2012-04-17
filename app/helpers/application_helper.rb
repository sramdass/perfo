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
  	  when  "Batch"
  	    edit_batch_path(obj)  	      	  	   
  	  when  "SchoolType"
  	    edit_school_type_path(obj)  	   
  	  when  "Student"
  	    edit_student_path(obj)  	      	
  	  when  "Section"
  	    edit_section_path(obj)  	     	      	     	       	     
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
  	  when  "Batch"
  	    batches_path    	  	  
  	  when  "SchoolType"
  	    school_types_path    	
  	  when  "Student"
  	    students_path    
  	  when  "Section"
  	    sections_path(obj)  	     	    	  	      	      
  	 when nil
  	    nil
    end
  end  
  
  def new_link(obj)
  	case obj.class.to_s
  	  when  "Tenant"
  	    new_tenant_path
  	  when  "Semester"
  	    new_semester_path  
  	  when  "Department"
  	    new_department_path
  	  when  "Subject"
  	    new_subject_path  
  	  when  "Faculty"
  	    new_faculty_path
  	  when  "Exam"
  	    new_exam_path
  	  when  "Batch"
  	    new_batch_path    	
  	  when  "SchoolType"
  	    new_school_type_path    	
  	  when  "Student"
  	    new_student_path    	 
  	  when  "Section"
  	    new_section_path(obj)  	     	     	    	      	    
  	 when nil
  	    nil
    end
  end    
  
	def link_to_remove_fields(name, f)
		f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
	end
	  

	# If extra local variables have to passed to the partial, they will passed in to params
	# If no extra variables are required, a blank hash will be used as a default value.	
	def link_to_add_fields(name, f, association, params={})
		new_object = f.object.class.reflect_on_association(association).klass.new
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			#merge the params hash with the form builder being sent as a local variable to the partial
	  		render(association.to_s.singularize + "_fields", {:f => builder}.merge(params))
		end
		link_to_function(name, "add_fields(this, '#{association}', '#{escape_javascript(fields)}')")
	end	    

end
