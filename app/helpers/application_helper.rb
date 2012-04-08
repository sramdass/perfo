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
  	 when nil
  	    nil
    end
  end

end
