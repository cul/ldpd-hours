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

  function disableWidget(widget) {
    if (widget.prop("disabled")) return;
    widget.prop("disabled", true);
    const selection = widget.children(':checked');
    selection.data('label', selection.text());
    selection.text('--');
  }
  function enableWidget(widget) {
    if (!widget.prop("disabled")) return;
    const selection = widget.children(':checked');
    selection.text(selection.data('label'));
    widget.prop("disabled", false);
  }

  const dateWidgetIds = ['#timetable_open_4i', '#timetable_open_5i', '#timetable_close_4i', '#timetable_close_5i']

  // On check of Closed, ensure TBD is unchecked
  $('input#timetable_closed').on("input", function () {
    if ($(this).is(':checked')) {
      $('input#timetable_tbd').prop( "checked", false );
      dateWidgetIds.forEach(function(widgetId) { disableWidget($(widgetId)) });
    } else {
      dateWidgetIds.forEach(function(widgetId) { enableWidget($(widgetId)) });
    }
  });
  // On check of TBD, ensure Closed is unchecked
  $('input#timetable_tbd').on("input", function () {
    if ($(this).is(':checked')) {
      $('input#timetable_closed').prop( "checked", false );
      dateWidgetIds.forEach(function(widgetId) { disableWidget($(widgetId)) });
    } else {
      dateWidgetIds.forEach(function(widgetId) { enableWidget($(widgetId)) });
    }
  });
  // On batch_edit form submit, add days and times to cal on success
  $('form#new_timetable').on('ajax:success', function(event, jqxhr, settings, exception){
    $( '.days-list' ).empty();
    const closedChecked = $('input#timetable_closed').is(':checked');
    const tbdChecked = $('input#timetable_tbd').is(':checked');
    const timetableNote = $('#timetable_note').val();
    $('.ui-selected').each(function(){
      var that = this;
      var replaceHours;
      if(closedChecked){
        replaceHours = '<div class="day-hours">Closed</div>';
      }else if(tbdChecked){
        replaceHours = '<div class="day-hours">TBD</div>';
      }else{
        replaceHours = location_hours();
      }
      $(this).children('.day-hours').replaceWith(replaceHours);
      if ($(this).children('.day-note').text(timetableNote).length == 0) {
        $(this).append('<div class="day-note">' + timetableNote + '</div>');
      }
    });
    if (closedChecked) $('input#timetable_closed').prop( "checked", false );
    if (tbdChecked) $('input#timetable_tbd').prop( "checked", false );
    dateWidgetIds.forEach(function(widgetId) { enableWidget($(widgetId)) });
    $('#timetable_note').val('');
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
    const leadZeros = /^0+/;
    var open = $('#timetable_open_4i option:selected').text().split(' ')[0] + ':' +
               $('#timetable_open_5i option:selected').text() +
               $('#timetable_open_4i option:selected').text().split(' ')[1];
    open = open.replace(leadZeros, '');
    var close = $('#timetable_close_4i option:selected').text().split(' ')[0] + ':' +
                $('#timetable_close_5i option:selected').text() +
                $('#timetable_close_4i option:selected').text().split(' ')[1];
    close = close.replace(leadZeros, '');
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
  var subscriptionsForThisPage = $('#alert-container').attr('data-subscriptions');
  subscriptionsForThisPage = subscriptionsForThisPage ? subscriptionsForThisPage.split(',') : [];
  $.ajax({ 
      type: 'GET',
      url: 'https://api.library.columbia.edu/query.json?qt=alerts',
      dataType: 'json',
      success: function (data) { 
        if(data['alerts'].length > 0) {
          data['alerts'].forEach(function(alert){
            var alertTargets = alert['targets'] || [];
            var matches = alertTargets.filter(function(target) { return subscriptionsForThisPage.indexOf(target) !== -1; });
            // Check to see if any of this pages's subscriptions match this alert's targets.
            if( matches.length === 0 ) {
                return; // no matches found
            }
            var $newAlertDiv = $('<div class="alert"></div>');
            if(alert['type'] == 'critical') { $newAlertDiv.addClass('alert-danger'); }
            if(alert['type'] == 'warning') { $newAlertDiv.addClass('alert-warning'); }
            if(alert['type'] == 'info') { $newAlertDiv.addClass('alert-info'); }
            $newAlertDiv.html(alert['html']);
            $('#alert-container').append($newAlertDiv);
          });
        }
      }
  });


  //Enable bootstrap 3 tooltips
  $('[data-toggle="tooltip"]').tooltip({html: true});
});
