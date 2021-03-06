function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".tfields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  /* $(link).parent().before(content.replace(regexp, new_id)); */
  $(".input_form_table").append(content.replace(regexp, new_id));
}

function populateDropdown(target, data, display_attr) {
  //Form the element id of the select object that needs to be populated.
  target_select = $('#' + target);
  target_select.html('');
  target_select.append($('<option></option>').val('').html(''));
  $.each(data, function(id, option) {
  	if (display_attr.toLowerCase() == "rabl_name") {  	
      target_select.append($('<option></option>').val(option.id).html(option.rabl_name));
    } else {
      target_select.append($('<option></option>').val(option.id).html(option.name));
    }
  });       
}

$(function() {
// This code is for the search form in Tenants index 
$("#tenant_expired").click(function() {
    if ($(this).is(":checked")) {
    	var current_date = $(this).attr('value');
        $("#tenant_subscription_to_gt").attr('value', current_date);
    } else {
        $("#tenant_subscription_to_gt").removeAttr('value');
    }
});

/************************************************************
Code to enable and disable in the view/exams/_exam_fields.erb
If the exam_type is checked off (meaning, this is an assignment) - 
	1. then we need to disable to Final Exam check box as the final exam check box 
	is only applicable for the type exams(not assignments)
	2. The 'examination_select' (the exam to which an assignment belongs should)
	be enabled.
	
If the exam_type is unchecked (meaning, this is an exam) - 	
	1. The 'finals' check box has to be enabled.
	2. exam_select drop down should be disabled, as selecting exams is
	only applicable for the assignments.
	
Note that this logic should execute while checking/un checking and the page load.	
*/
//During checking / unchecking.
$("#exam_type_check_box").click(function() {     
	if ($(this).is(":checked")) {
		$("#examination_select").removeAttr('disabled');
		//$("#finals_check_box").val("");
		$("#finals_check_box").attr('disabled', 'disabled');				
    } else {
		//$("#examination_select").val("");
		$("#examination_select").attr('disabled', 'disabled');
		$("#finals_check_box").removeAttr('disabled');
    }		
});

//During the page load
if ($("#exam_type_check_box").is(":checked")) {
		$("#examination_select").removeAttr('disabled');	
		//$("#finals_check_box").val("");
		$("#finals_check_box").attr('disabled', 'disabled');						
	} else {
		//$("#examination_select").val("");
		$("#examination_select").attr('disabled', 'disabled');
		$("#finals_check_box").removeAttr('disabled');		
    }
    
/*
Code to enable and disable in the view/exams/_exam_fields.erb
If the 'finals' is checked off (meaning, this is a semester exam) - 
	1. then we need to disable to assignment check box and the exam_select
	dropdown box
	
If the 'finals' is unchecked (meaning, this is an not a semester exam) - 	
	1. The 'assignment' check box has to be enabled.
	2. exam_select drop down should be disabled/enabled after checking
	whether the assignment check box is checked off or not/
	
Note that this logic should execute while checking/un checking and the page load.	
*/
//During checking / unchecking.
$("#finals_check_box").click(function() {     
	if ($(this).is(":checked")) {
		//$("#exam_type_check_box").val("");
		$("#exam_type_check_box").attr('disabled', 'disabled');						
		//$("#examination_select").val("");
		$("#examination_select").attr('disabled', 'disabled');		
    } else {
		$("#exam_type_check_box").removeAttr('disabled');
		if ($("#exam_type_check_box").is(":checked")) {
			$("#examination_select").removeAttr('disabled');	    	
		}
    }		
});

//During the page load
if ($("#finals_check_box").is(":checked")) {
		$("#exam_type_check_box").val("");
		$("#exam_type_check_box").attr('disabled', 'disabled');						
		$("#examination_select").val("");
		$("#examination_select").attr('disabled', 'disabled');					
	} else {
		$("#examination_select").removeAttr('disabled');	    	
		$("#exam_type_check_box").removeAttr('disabled');
    }
    
/************************************************************/        
    
$('.datatable_full').dataTable();
  
//For the selector forms. Refer _marks_form.html.erb and _form.html.erb in views\selectors\
//Note that this is not applicable for the reports form. The ids have been changed for the select
//boxes in the _reports_form in view\selectors\
$('#batch-selector, #section-selector, #exam-selector, #selector-submit ').attr('disabled', 'disabled');

$('.selector-form').submit(function() {
	$.get($(this).data("target_url"), $(this).serialize(), null, "script");
    return false;
});  

//To enable, disable, populate the selector forms.
//Refer _marks_form.html.erb and _form.html.erb in views\selectors\
$(".selector-form select, .selector-form-html select").live("change",function() {     
	//The child select box of the current select box
  	var target = $(this).data('target');
  	//Form the element id of the select object that needs to be populated.
  	target_select = $('#' + target);
  	//If some value is selected in the current select box, populate the child select box.
  	//Otherwise, disable all the child select boxes and the submit button.
  	if ($(this).val() != "") {
  		target_select.removeAttr('disabled');
  	} else {
  		//Traverse to find all the children. When the selector is of zero length, we know
  		//it is not a valid selector.
  		while(target_select.length) {
  			//Do not change the value of the submit button. Otherwise the button will
  			//not have anything written in it. For the select boxes, make the value as blank
  	  		if (target_select.attr("type") != "submit"){
  	    		target_select.val("");
  	  		}
  	  		//Disable the select box or the submit button
  	  		target_select.attr('disabled', 'disabled');
  	  		//Find the next child item that has to be disabled. If it is the last child, the submit button,
  	  		//it will not have any further children, and the selector will not be valid (length = zero)
  	  		target_select = $('#' + target_select.data('target'))
  	  	}
  	}
  	//After disabling/enabling, do the data population. Note that this part of the code is still in the change event.
	$.get("/selectors", 
	  			{ 
  				required: $(this).data('required'), 
  				department_id: $('#department-selector').val(),
  				batch_id: $('#batch-selector').val(),
  				section_id: $('#section-selector').val(),
  				semester_id: $('#semester-selector').val(),
  				exam_id: $('#exam-selector').val()
  			}, //parameters
  			function(dyndata) { //this function will have the data that is returned
  			  //call to populate the data. The signature is - 
  			  //(the-select-id-to-populate, data-source, attr-name-to-pick-from-the-data-array-4-display)
  			  //note that rabl_name is used for marks form and the other selector forms
      		  populateDropdown(target, dyndata, "rabl_name"); 
  			}, 
  			"json"); //Type of the request should be specified
});   //End of the change event handler.


//To enable, disable, populate the report selector forms.
//Refer _marks_form.html.erb and _form.html.erb in views\selectors\
$(".report-selector-form select").live("change",function() {     
	//We need to declare the following 2 variables as we are using split(), and length() on
	//these two variables.
	//1. to hold the array of required resources ('required' data attribute in the current select box)
	var required_resources = [];
	//2. to hold the array of targets ('target' data attribute in the current select box)
	var targets = [];
	
	//Check if the following data attributes are valid as we are using split() on these variables.
	//refer the :section_id select box in the _reports_form.html.erb
	if (undefined !== $(this).data('target')) {
		targets = $(this).data('target').split(",");
	}
	if (undefined !== $(this).data('required')) {
		required_resources = $(this).data('required').split(",");
	}			
	
	//Note that there should be a one on one mapping between the required resources and the targets.
	//Loop through each of the required_resources, do the get request and populate the corresponding
	//target. We need the loop, incase there are more than one resource to be fetched by the get request.
	//refer the :section_id select box in the _reports_form.html.erb
	for(var index=0; index< required_resources.length; index++) {
		//Trim the leading and trailing white spaces. otherwise, those will be encoded and the parameters
		//of the get request will be corrupted
		var target = $.trim(targets[index]);
  	    //The select box to be populated in this iteration
  	    target_select = $('#' + target);
  	    //If some value is selected in the current select box, populate the child select box.
  	    //Otherwise, empty all the child select
  	    if ($(this).val() == "") {
  	    	//Traverse to find all the children. When the selector is of zero length, we know
  	    	//it is not a valid selector.
  	    	while(target_select.length) {
        		target_select.html('');
                target_select.append($('<option></option>').val('').html(''));
  	      		//Find the next child item that has to be emptied. If it is the last child
  	      		//it will not have any further children, and the selector will not be valid (length = zero)
  	      		target_select = $('#' + target_select.data('target'))
  	      	}
  	    }
  	    //After disabling/enabling, do the data population. Note that this part of the code is still in the change event.
	    $.ajax({
	    	url: "/selectors/report_selector", 
  			dataType: 'json',  
  			data: 	{ 
  	    					required: required_resources[index], 
  	    					department_id: $('#rep-department-selector').val(),
  	    					batch_id: $('#rep-batch-selector').val(),
  	    					section_id: $('#rep-section-selector').val(),
  	    					student_id: $('#rep-student-selector').val(),
  	    					semester_id: $('#rep-semester-selector').val(),
  	    					exam_id: $('#rep-exam-selector').val()
  	    				}, 
  	  		async: false,
  	      	success:	function(dyndata) { 
  	    		  				//call to populate the data. The signature is - 
  	    		  				//(the-select-id-to-populate, data-source, attr-name-to-pick-from-the-data-array-4-display)
  	    		  				//note that 'name' (not rabl_name) is used for reports form and the other selector forms  	
          		  				populateDropdown(target, dyndata, "name");
  	    				}, 
  	  });
	}
});   //End of the change event handler.

//Roles.
//hide the textbox with through which the permission values are sent.
$('.resource_permissions input.total_permission').hide();
  
$(".resource_permissions input:checkbox").click(function() {
    var amount = 0;
    var existing_value = $(this).parents('.resource_permissions:first').find('.total_permission').val();
    if (existing_value.length > 0 ){
      amount = parseInt(existing_value);
    }
    if ($(this).is(":checked")) {
        amount += parseInt($(this).attr('value'));
    } else {
        amount -= parseInt($(this).attr('value'));
    }
    //$(this).closest('input:text').val(amount);
    //$(this).parent("div").find("input[type=text]").val(amount);
    $(this).parents('.resource_permissions:first').find('.total_permission').val(amount);
});

$(document).on("click", ".token-input", null, function(){
    $(this).tokenInput(function() {  
		return '/selectors/students.json';
	}, 	{
    	crossDomain: false,
    	prePopulate: $(this).data("pre"),
    	propertyToSearch: 'rabl_name',
    	preventDuplicates: true,
    	minChars: 3
    	//theme: "facebook"
    });
});

});