(function() {
  $(function() {
    $('#clients').chosen({
      placeholder_text_multiple: 'All Clients',
      no_results_text: 'No results matched'
    });
    $('#projects').chosen({
      placeholder_text_multiple: 'All Projects',
      no_results_text: 'No results matched'
    });
    $('#tasks').chosen({
      placeholder_text_multiple: 'All Tasks',
      no_results_text: 'No results matched'
    });
    $('#people').chosen({
      placeholder_text_multiple: 'All People',
      no_results_text: 'No results matched'
    });

    if(has_time_entries) {
      $(".filter form").addClass('hidden');
      $(".filter > .btn").removeClass('hidden');
      $(".filter .btn").click(function(){
        $(".filter form").removeClass('hidden');
        $(".filter > .btn").addClass('hidden');
      });
      // $('.nav-tabs a').click(function (e) {
      //   console.debug("hola");
      //   e.preventDefault()
      //   $(this).tab('show')
      // });
    }
    options = {
      responsive : true,
      graphMin : 0,
      // graphMax : 100,
      yAxisLeft: false,
      // barStrokeWidth : 3,
      barShowStroke : false,
      annotateDisplay : true,
      annotateLabel : "<%=v1%>: <%=v3%>h (<%=v6%>%)",
      // annotateLabel: "<%=(v1 == '' ? '' : v1) + (v1!='' && v2 !='' ? ' - ' : '')+(v2 == '' ? '' : v2)+(v1!='' || v2 !='' ? ':' : '') + v3 + ' (' + v6 + ' %)'%>"
      // scaleShowLabels: false,
      // scaleShowGridLines: false,
    }
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      // console.debug($(this).attr('href').substr(5));
      $('#canvasDiv').empty();
      $('#canvasDiv').append('<canvas id="canvas" height="25"></canvas>');
      ctx = document.getElementById("canvas").getContext("2d");
      window.horizontalBar = new Chart(ctx).HorizontalStackedBar(data[$(this).attr('href').substr(5)], options);
    });

  });
}).call(this);