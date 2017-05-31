$(document).ready(function(){

	// remove admin
    $('ul li i.fa-times').on('click', function( data, status, xhr) {
	  $(this).parent().parent().remove();
	});
	
});