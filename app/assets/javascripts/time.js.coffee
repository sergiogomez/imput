# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#time_entry_project_id').chosen
    no_results_text: 'No results matched'
  $('#time_entry_task_id').chosen
    no_results_text: 'No results matched'
  $("#time_entry_task_id").change(->
    $("#time_entry_task_id").trigger("chosen:updated")
  )
  $('select[data-dynamic-selectable-url][data-dynamic-selectable-target]').dynamicSelectable()
