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
        var date = formatted_date($(this).contents().filter(function() { return this.nodeType == 3; })[0].nodeValue)
        $(".days-list").append("<li>" + date + "</li>").append("<input type='hidden' name='time_table[dates][]' value='" + date + "'>")
      });
    }
  });

  function formatted_date(day){
    var month = $(".well.controls").text().trim().split(" ")[0];
    var year = $(".well.controls").text().trim().split(" ")[1];
    var myDate = new Date(month + ", " + day + " " + year);
    return myDate.getMonth(month) + "/" + day.trim() + "/" + year;
  }

  // On batch_edit form submit, add days and times to cal on success
  $(document).bind('ajax:success', 'form#new_time_table', function(event, jqxhr, settings, exception){
    $( ".days-list" ).empty();
    $(".ui-selected").each(function(){
      var that = this;
      $.when($(this).children("span").remove()).then(function(){
        $(that).append(library_hours)
      });
    });
    $("td").removeClass("ui-selected");
  });

  function library_hours(){
    var open = $("#time_table_open_4i option:selected").text().split(" ")[0] + ":" + 
               $("#time_table_open_5i option:selected").text() + 
               $("#time_table_open_4i option:selected").text().split(" ")[1]
    var close = $("#time_table_close_4i option:selected").text().split(" ")[0] + ":" + 
                $("#time_table_close_5i option:selected").text() + 
                $("#time_table_close_4i option:selected").text().split(" ")[1]
    return "<span>" + open + "-" + close + "</span>"
  }

});