(function() {
  $(function() {
    return $('select[data-dynamic-selectable-url][data-dynamic-selectable-target]').dynamicSelectable();
  });
}).call(this);

$(function () {
  if($('.timer .btn-sm').attr('href')){
    // link = $('.timer .btn-sm')[0].href;
    link = $('.timer .btn-sm').attr('href');
    link = link.replace('stop', 'start');
    dup_link = link.replace('start', 'duplicate');
    if(!same_day) {
      $('.timer .btn-sm').popover(
        {
          html: true,
          trigger: 'manual',
          delay: { "show": 100, "hide": 100 },
          placement : 'bottom',
          title: '<strong>Sorry, but this task is not from today</strong>',
          content: '<p class="text-center">' +
            //'<a href="' + link + '" class="btn btn-xs btn-primary" data-method="patch" data-remote="true"><i class="fa fa-play"></i> Start ' + date + '</a> ' +
            '<a href="' + dup_link + '" class="btn btn-sm btn-success" data-method="patch" data-remote="true"><i class="fa fa-play"></i> Start Today</a> ' +
            '<span class="btn btn-sm btn-default cancel">Cancel</span> ' +
            '</p>',
          container: 'body'
        }
      );
    }
    $('.timer .btn-sm').click(function(){
      if(!same_day) {
        if(running) {
          $('.timer .btn-sm').popover('hide');
        } else {
          $('.timer .btn-sm').popover('show');
          $('.timer .btn-sm').addClass('disabled');
          $('.cancel').click(function(){
            removePopover();
          });
          $('html').click(function() {
            removePopover();
          });
          return false;
        }
      }
    });
  }
  $('.nav-projects a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    for(var i=0; i<projects[$(this).attr('href')].length; i++){
      doughnutProjects.segments[i].value = projects[$(this).attr('href')][i]['value'];
    }
    doughnutProjects.update();
  });
  $('.nav-tasks a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    for(var i=0; i<tasks[$(this).attr('href')].length; i++){
      doughnutTasks.segments[i].value = tasks[$(this).attr('href')][i]['value'];
    }
    doughnutTasks.update();
  });
  $('.nav-clients a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    for(var i=0; i<clients[$(this).attr('href')].length; i++){
      doughnutClients.segments[i].value = clients[$(this).attr('href')][i]['value'];
    }
    doughnutClients.update();
  });

  options = {
    segmentShowStroke : true,
    segmentStrokeColor : "#fff",
    segmentStrokeWidth : 2,
    percentageInnerCutout : 50, // This is 0 for Pie charts
    animationSteps : 50,
    animationEasing : "easeIn",
    animateRotate : true,
    animateScale : false,
  };

  projects = {};
  clients = {};
  tasks = {};

  ctxProjects = document.getElementById("chartProjects").getContext("2d");
  ctxClients =  document.getElementById("chartClients").getContext("2d");
  ctxTasks =    document.getElementById("chartTasks").getContext("2d");

});

function removePopover() {
  if($('.timer .btn-sm').hasClass('disabled')){
    $('.timer .btn-sm').removeClass('disabled');
    $('.timer .btn-sm').popover('hide');
  }
}

Chart.defaults.global = {
    animation: true,
    animationSteps: 60,
    animationEasing: "easeOutQuart",
    showScale: true,
    scaleOverride: false,
    scaleSteps: null,
    scaleStepWidth: null,
    scaleStartValue: null,
    scaleLineColor: "rgba(0,0,0,.1)",
    scaleLineWidth: 1,
    scaleShowLabels: true,
    scaleLabel: "<%=value%>",
    scaleIntegersOnly: true,
    scaleBeginAtZero: false,
    scaleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    scaleFontSize: 12,
    scaleFontStyle: "normal",
    scaleFontColor: "#666",
    responsive: true,
    maintainAspectRatio: true,
    showTooltips: true,
    tooltipEvents: ["mousemove", "touchstart", "touchmove"],
    tooltipFillColor: "rgba(0,0,0,0.8)",
    tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    tooltipFontSize: 14,
    tooltipFontStyle: "normal",
    tooltipFontColor: "#fff",
    tooltipTitleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    tooltipTitleFontSize: 14,
    tooltipTitleFontStyle: "bold",
    tooltipTitleFontColor: "#fff",
    tooltipYPadding: 6,
    tooltipXPadding: 6,
    tooltipCaretSize: 8,
    tooltipCornerRadius: 6,
    tooltipXOffset: 10,
    tooltipTemplate: "<%if (label){%><%=label%>: <%}%><%= Math.round((circumference / 6.283)*100) %>% (<%= Math.round(value * 100) / 100 %>h)",
    multiTooltipTemplate: "<%= value %>",
    onAnimationProgress: function(){},
    onAnimationComplete: function(){}
}
