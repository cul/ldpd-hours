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
        var date = $(this).children("p").text();
        $(".days-list").append("<li>" + date + "</li>").append("<input type='hidden' name='timetable[dates][]' value='" + date + "'>")
      });
    }
  });

  // On batch_edit form submit, add days and times to cal on success
  $('form#new_timetable').on('ajax:success', function(event, jqxhr, settings, exception){
    $( ".days-list" ).empty();
    $(".ui-selected").each(function(){
      var that = this;
      $.when($(this).children("span").remove()).then(function(){
        if($("input#timetable_closed").is(":checked")){
          $(that).append("<span>Closed</span>");
        }else if($("input#timetable_tbd").is(":checked")){
          $(that).append("<span>TBD</span>");
        }else{
          $(that).append(location_hours);
        }

        if($("#timetable_note").val()){
          $(that).append("<span>" + $("#timetable_note").val() + "</span>");
          $("#timetable_note").val('');
        }
      });
    });
    $("td").removeClass("ui-selected");
  });

  $('form#new_timetable').on('ajax:error', function(event, jqxhr, settings, exception){
    $( ".days-list" ).empty();
    $(".ui-selected").each(function(){
      $(this).children("span").remove();
    });
    $("td").removeClass("ui-selected");
    $("#timetable_note").val('');
    $("div.body-contain").prepend("<div class='alert alert-danger'><a href='#' data-dismiss='alert' class='close'>×</a><ul><li>Please Enter Valid Data</li></ul></div>");
  });

  function location_hours(){
    var open = $("#timetable_open_4i option:selected").text().split(" ")[0] + ":" +
               $("#timetable_open_5i option:selected").text() +
               $("#timetable_open_4i option:selected").text().split(" ")[1]
    var close = $("#timetable_close_4i option:selected").text().split(" ")[0] + ":" +
                $("#timetable_close_5i option:selected").text() +
                $("#timetable_close_4i option:selected").text().split(" ")[1]
    return "<span>" + open + "-" + close + "</span>"
  }

  $('form#batch_edit').on('ajax:error', function(event, jqxhr, settings, exception){
    $("div.body-contain").prepend("<div class='alert alert-danger'><a href='#' data-dismiss='alert' class='close'>×</a><ul><li>Please Enter Valid Data</li></ul></div>");
  });

  $('form#batch_edit').on('ajax:success', function(event, jqxhr, settings, exception){
    $("div.body-contain").prepend("<div class='alert alert-success'><a href='#' data-dismiss='alert' class='close'>×</a><ul><li>Dates Successfully Added</li></ul></div>");
  });

});
