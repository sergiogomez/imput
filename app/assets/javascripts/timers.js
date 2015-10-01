var timer = 0;
var running = false;
var interval = 36000; // 36000
var increment = 1/100; // 1/100

$(function () {
  if(nice) {
    interval = 1000; // 1000
    increment = 1; // 1
  }
  if(running) {
    updateValues(timer);
    globalTimer = setInterval(updateValues, interval, increment); // 36000
  }
});

function setField(selectors, value){
  if($(selectors).length) {
    $(selectors).html(value);
  }
}

function updateField(selectors, inc){
  if($(selectors).length) {
    if(nice) {
      field_init = filterTimeFormat($(selectors).html().trim());
      field = (field_init + inc).toHHMMSS();
    } else {
      field_init = parseFloat($(selectors).html().trim());
      field = (field_init + inc).toFixed(2);
    }
    $(selectors).html(field);
  }
}

function updateValues(inc){
  updateField('table.day tr.success td.time', inc);
  updateField('table.day tr.timer td.time', inc);
  updateField('table.day th.timer span.time', inc);
  updateField('table.day th.timer ~ th.total span.time', inc);

  updateField('table.week tbody td.timer', inc);
  updateField('table.week tfoot td.timer', inc);
  updateField('table.week tbody td.timer ~ td.total', inc);
  updateField('table.week tfoot td.timer ~ td.total', inc);
  
  updateField('table.dashboard td.time', inc);
}

// https://gist.github.com/peterchester/2980896
function filterTimeFormat(time) {
 
  // Number of decimal places to round to
  var decimal_places = 2;
 
  // Maximum number of hours before we should assume minutes were intended. Set to 0 to remove the maximum.
  var maximum_hours = 15;
 
  // 3
  var int_format = time.match(/^\d+$/);
 
  // 1:15
  var time_format = time.match(/([\d]*):([\d]+)/);
 
  // 1:15:00
  var time_full_format = time.match(/([\d]*):([\d]+):([\d]+)/);
 
  // 10m
  var minute_string_format = time.toLowerCase().match(/([\d]+)m/);
 
  // 2h
  var hour_string_format = time.toLowerCase().match(/([\d]+)h/);
 
  if (time_format != null) {
    hours = parseInt(time_format[1] * 3600);
    minutes = parseInt(time_format[2] * 60);
    if (time_full_format != null) {
      seconds = parseInt(time_full_format[3]);
    } else {
      seconds = 0;
    }
    if (time.match(/-/)) {
      time = - (hours + minutes + seconds);
    } else {
      time = hours + minutes + seconds;
    }
  } else if (minute_string_format != null || hour_string_format != null) {
    if (hour_string_format != null) {
      hours = parseInt(hour_string_format[1] * 3600);
    } else {
      hours = 0;
    }
    if (minute_string_format != null) {
      minutes = parseInt(minute_string_format[1] * 60);
    } else {
      minutes = 0;
    }
    time = hours + minutes;
  } else if (int_format != null) {
    // Entries over 15 hours are likely intended to be minutes.
    time = parseInt(time);
    if (maximum_hours > 0 && time > maximum_hours) {
      time = (time/60).toFixed(decimal_places);
    }
  }

  // make sure what ever we return is a 2 digit float
  time = parseInt(time); //.toFixed(decimal_places);
 
  return time;
}

// http://stackoverflow.com/questions/6312993/javascript-seconds-to-time-string-with-format-hhmmss
Number.prototype.toHHMMSS = function () {
  var sign    = '';
  if (this < 0)     {sign    = "-";}
  abs_value = Math.abs(this);
  var sec_num = parseInt(abs_value, 10); // don't forget the second param
  var hours   = Math.floor(sec_num / 3600);
  var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
  var seconds = sec_num - (hours * 3600) - (minutes * 60);

  if (hours   < 10) {hours   = "0"+hours;}
  if (minutes < 10) {minutes = "0"+minutes;}
  if (seconds < 10) {seconds = "0"+seconds;}
  var time    = sign+hours+':'+minutes+':'+seconds;
  return time;
  }
