$(document).ready(function(){
  // Unchecking/checking boxes if a user becomes an admin.
  $('#user_permissions_admin_true, #user_permissions_admin_false').on("change rightnow", function(e){
    if($('#user_permissions_admin_true').is(':checked')) {
      $('.chk-edit-permissions')
        .attr('disabled', true)
        .prop('checked', true);
    } else if(e.type == 'change') {
      $('.chk-edit-permissions')
        .attr('disabled', false)
        .prop('checked', false)
    }
  }).triggerHandler('rightnow');
});
