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