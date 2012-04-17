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
  
});