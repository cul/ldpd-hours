$(document).ready(function(){
  // remove admin
  $('ul li i.fa-times').on('click', function( data, status, xhr) {
    $(this).parent().parent().remove();
  });

  // Calendar add selected days to ul
  $('#selectable').selectable({
    filter:'tbody tr td',
    selected: function(event, ui){
      $( '.days-list' ).empty();
      $( '.ui-selected', this ).each(function() {
        var date = $(this).children('.fulldate').text();
        $('.days-list').append('<li>' + date + '</li>').append('<input type="hidden" name="timetable[dates][]" value="' + date + '">');
      });
    }
  });

  // On batch_edit form submit, add days and times to cal on success
  $('form#new_timetable').on('ajax:success', function(event, jqxhr, settings, exception){
    $( '.days-list' ).empty();
    $('.ui-selected').each(function(){
      var that = this;
      $.when($(this).children('.day-hours').remove()).then(function(){
        if($('input#timetable_closed').is(':checked')){
          $(that).append('<div class="day-hours">Closed</div>');
        }else if($('input#timetable_tbd').is(':checked')){
          $(that).append('<div class="day-hours">TBD</div>');
        }else{
          $(that).append(location_hours);
        }

        if($('#timetable_note').val()){
          $(that).append('<div class="day-hours">' + $('#timetable_note').val() + '</div>');
          $('#timetable_note').val('');
        }
      });
    });
    $('td').removeClass('ui-selected');
  });

  var parseEventJSON = function(event) {
    var jsonSrc = event.detail[2].responseText;
    return jsonSrc ? jQuery.parseJSON(event.detail[2].responseText) : {};
  };

  $('form#new_timetable').on('ajax:error', function(event, jqxhr, settings, exception){
    $( '.days-list' ).empty();
    $('.ui-selected').each(function(){
      $(this).children('.day-hours').remove();
    });
    $('td').removeClass('ui-selected');
    $('#timetable_note').val('');
    var message = "Please Enter Valid Data";
    var resp =  parseEventJSON(event);
    if (resp['message']) {
      message = message + ': ' + resp['message'];
    }
    $('div.body-contain').prepend('<div class="alert alert-danger"><a href="#" data-dismiss="alert" class="close">×</a><ul><li>' + message + '</li></ul></div>');
  });
  $('form#new_timetable').on('ajax:success', function(event, jqxhr, settings, exception){
    var resp = parseEventJSON(event);
    if (resp['status'] == 'warning') {
      $('div.body-contain').prepend('<div class="alert alert-warning"><a href="#" data-dismiss="alert" class="close">×</a><ul><li>' + resp['message'] + '</li></ul></div>');
    }
  });

  function location_hours(){
    var open = $('#timetable_open_4i option:selected').text().split(' ')[0] + ':' +
               $('#timetable_open_5i option:selected').text() +
               $('#timetable_open_4i option:selected').text().split(' ')[1]
    var close = $('#timetable_close_4i option:selected').text().split(' ')[0] + ':' +
                $('#timetable_close_5i option:selected').text() +
                $('#timetable_close_4i option:selected').text().split(' ')[1]
    return '<div class="day-hours">' + open + '-' + close + '</div>'
  }

  $('form#batch_edit').on('ajax:error', function(event, jqxhr, settings, exception){
    $('div.body-contain').prepend('<div class="alert alert-danger"><a href="#" data-dismiss="alert" class="close">×</a><ul><li>Please Enter Valid Data</li></ul></div>');
  });

  $('form#batch_edit').on('ajax:success', function(event, jqxhr, settings, exception){
    var resp = parseEventJSON(event);
    if (resp['status'] == 'warning') {
      $('div.body-contain').prepend('<div class="alert alert-warning"><a href="#" data-dismiss="alert" class="close">×</a><ul><li>' + resp['message'] + '</li></ul></div>');
    } else {
      $('div.body-contain').prepend('<div class="alert alert-success"><a href="#" data-dismiss="alert" class="close">×</a><ul><li>Dates Successfully Added</li></ul></div>');
    }
  });
  $.ajax({ 
      type: 'GET', 
      url: 'https://api.library.columbia.edu/query.json?qt=alerts',
      dataType: 'json',
      success: function (data) { 
        if(data['alerts'].length > 0) {
          data['alerts'].forEach(function(alert){
            var $newAlertDiv = $('<div class="alert"></div>');
            if(alert['type'] == 'critical') { $newAlertDiv.addClass('alert-danger'); }
            if(alert['type'] == 'warning') { $newAlertDiv.addClass('alert-warning'); }
            if(alert['type'] == 'info') { $newAlertDiv.addClass('alert-info'); }
            $newAlertDiv.html(alert['html']).attr('role','alert');
            $('#alert-container').append($newAlertDiv);
          });
        }
      }
  });
});
