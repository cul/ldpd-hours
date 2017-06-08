$(document).ready(function(){

	// remove admin
    $('ul li i.fa-times').on('click', function( data, status, xhr) {
	  $(this).parent().parent().remove();
	});

    // update and remove superadmin status
	$('ul li i.fa-user-circle').on('click', function(data, status, xhr){
		$(this).toggleClass("admin-color");
	});

	// Calendar add selected days to ul
	$("#selectable").selectable({
	  filter:'tbody tr td',
	  selected: function(event, ui){
	  	$( ".days-list" ).empty();
		$( ".ui-selected", this ).each(function() {
			var date = formatted_date($(this).text())
		 	$(".days-list").append("<li>" + date + "</li>").append("<input type='hidden' name='time_table[dates][]' value='" + date + "'>")
		});
	  }
	});

	function formatted_date(day){
		var month = $(".well.controls").text().trim().split(" ")[0];
		var year = $(".well.controls").text().trim().split(" ")[1];
		var myDate = new Date(month + ", " + day + " " + year);
		return myDate.toLocaleDateString("en-US")
	}

	// On batch_edit form submit

	$(document).bind('ajax:success', 'form#new_time_table', function(event, jqxhr, settings, exception){
		console.log("form submitted");
		$( ".days-list" ).empty();
	});

});