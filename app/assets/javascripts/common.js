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

function populateDropdown(select, data) {
  select.html('');
  select.append($('<option></option>').val('').html(''));
  $.each(data, function(id, option) {
    select.append($('<option></option>').val(option.id).html(option.rabl_name));
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
	
$('.datatable_full').dataTable();
  
//For the selector forms. Refer _marks_form.html.erb and _form.html.erb in views\selectors\
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
  			{ base: $(this).data('base'), required: $(this).data('required'), base_id: $(this).val() }, //parameters
  			function(dyndata) { //this function will have the data that is returned
      		  populateDropdown(target_select, dyndata); //call to populate the data
  			}, 
  			"json"); //Type of the request should be specified
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