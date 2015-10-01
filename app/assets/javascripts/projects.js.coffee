# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#project_client_id').chosen
    no_results_text: 'No results matched'
  $('#project_task_ids').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
  $('#project_person_ids').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
  $('#project_project_manager_ids').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
