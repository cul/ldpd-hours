$(document).ready(function(){
  // Unchecking/checking boxes if a user becomes an admin.
  $('#user_permissions_role_editor, #user_permissions_role_manager, #user_permissions_role_administrator').on("change rightnow", function(e){
    if($('#user_permissions_role_manager, #user_permissions_role_administrator').is(':checked')) {
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
