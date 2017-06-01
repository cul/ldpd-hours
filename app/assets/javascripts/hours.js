$(document).ready(function(){

	// remove admin
    $('ul li i.fa-times').on('click', function( data, status, xhr) {
	  $(this).parent().parent().remove();
	});

    // update and remove superadmin status
	$('ul li i.fa-user-circle').on('click', function(data, status, xhr){
		$(this).toggleClass("admin-color");
	});

});