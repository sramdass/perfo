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
/* This code is for the search form in Tenants index */
$("#tenant_expired").click(function() {
    if ($(this).is(":checked")) {
        var current_date = $(this).attr('value');
        $("#tenant_subscription_to_gt").attr('value', current_date);
    } else {
        $("#tenant_subscription_to_gt").removeAttr('value');
    }
	});
	
  $('.datatable_full').dataTable();
  
$('.selector-form').submit(function() {
	alert('Submitting form!');
    $.get($(this).data("target_url"), $(this).serialize(), null, "script");
    return false;
  });  
  
$(".selector-form select").change(function() {     
  var target = $(this).data('target');
  //Form the element id of the select object that needs to be populated.
  target_select = $('#' + target);
  $.get("/selectors", 
  			{ base: $(this).data('base'), required: $(this).data('required'), base_id: $(this).val() }, 
  			function(dyndata) {
      		  populateDropdown(target_select, dyndata);
  			}, 
  			"json");
  });  
  
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
  
});