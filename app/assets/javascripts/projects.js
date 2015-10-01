(function() {
  $(function() {
    // $('#project_client_id').chosen({
    //   no_results_text: 'No results matched'
    // });
    $('#project_task_ids').chosen({
      allow_single_deselect: true,
      no_results_text: 'No results matched'
    });
    $('#project_person_ids').chosen({
      allow_single_deselect: true,
      no_results_text: 'No results matched'
    });
    return $('#project_project_manager_ids').chosen({
      allow_single_deselect: true,
      no_results_text: 'No results matched'
    });
  });

}).call(this);

$(function () {
  disable_form_calls = 0;
  last_value = $('#project_client_id').val();
  $('#add-client').hide();
  $('#project_client_id').append('<option value="-1" disabled>──────────</option>');
  $('#project_client_id').append('<option value="0">Add a new client</option>');
  $("#project_client_id").change(function() {
    if($(this).val()==0) {
      showNewClientForm();
    } else {
      last_value = $(this).val();
      hideNewClientForm();
    }
  });
  $('#add-task').hide();
  $('#new-task .btn').click(function(){
    showNewTaskForm();
    return false;
  })
});

function showNewTaskForm() {
  $('#new-task').slideUp('fast');
  $('#add-task .task-cancel').click(function(){
    hideNewTaskForm();
    return false;
  });
  $('#add-task .task-submit').click(function(){
    addTask();
    return false;
  });
  $('#add-task').slideDown('fast', function(){
    $('#project_tasks_task').focus();
    disableForm();
    $("#project_tasks_task").keypress(function(event) {
      if (event.which == 13) {
        event.preventDefault();
        addTask();
      }
    });
    $(document).keyup(function(e) {
      if (e.keyCode == 27) {
        hideNewTaskForm();
      }
    });
  });
  $('#project_tasks_task').keypress(function(){
    removeTaskErrors();
  });
}

function hideNewTaskForm() {
  if($('#add-task').is(":visible")) {
    removeTaskErrors();
    $('#project_tasks_task').val('');
    $('#project_task_ids').trigger('chosen:activate');
    $('#project_tasks_task').unbind('keypress');
    $(document).unbind('keyup');
    $('#add-task .task-cancel').unbind('click');
    $('#add-task .task-submit').unbind('click');
    $('#project_tasks_task').unbind('keypress');
    enableForm();
    $('#add-task').slideUp('fast');
    $('#new-task').slideDown('fast');
  }
}

function addTask() {
  removeTaskErrors();
  task = $('#project_tasks_task').val();
  $.ajax({
    type: "POST",
    url: "/tasks",
    data: {
      'task': { name: task }
    },
    dataType : 'json',
    success : function(data) {
      if(data.error) {
        $('#add-task .input').addClass('has-error');
        $('#project_tasks_task').after('<span class="help-inline">' + data.messages.name[0] + '</span>');
      } else {
        hideNewTaskForm();
        $('#project_task_ids').append('<option selected value="' + data.id + '">' + data.name + '</option>');
        $('#project_task_ids').trigger('chosen:updated');
      }
    },
    error: function(msg) {
      removeTaskErrors();
      $('#add-task .input').addClass('has-error');
      $('#project_tasks_task').after('<span class="help-inline">Connection refused</span>');
    }
  });
}

function removeTaskErrors() {
  $('#add-task .input').removeClass('has-error');
  if($('#add-task .input .help-inline').length) {
    $('#add-task .input .help-inline').remove();
  }
}

function showNewClientForm() {
  $('#add-client .client-cancel').click(function(){
    hideNewClientForm();
    return false;
  });
  $('#add-client .client-submit').click(function(){
    addClient();
    return false;
  });
  $('#add-client').slideDown('fast', function(){
    $('#project_client_name').focus();
    disableForm();
    $("#project_client_name").keypress(function(event) {
      if (event.which == 13) {
        event.preventDefault();
        addClient();
      }
    });
    $(document).keyup(function(e) {
      if (e.keyCode == 27) {
        hideNewClientForm();
      }
    });
  $('#project_client_name').keypress(function(){
    removeClientErrors();
  });
  });
}

function hideNewClientForm() {
  if($('#add-client').is(":visible")) {
    removeClientErrors();
    $('#project_client_name').val('');
    $('#project_client_id').val(last_value);
    $('#project_client_id').focus();
    $('#project_client_name').unbind('keypress');
    $(document).unbind('keyup');
    $('#add-client .client-cancel').unbind('click');
    $('#add-client .client-submit').unbind('click');
    $('#project_client_name').unbind('keypress');
    enableForm();
    $('#project_client_name').val('');
    $('#add-client').slideUp('fast');
  }
}

function removeClientErrors() {
  $('#add-client .input').removeClass('has-error');
  if($('#add-client .input .help-inline').length) {
    $('#add-client .input .help-inline').remove();
  }
}

function addClient() {
  removeClientErrors();
  client = $('#project_client_name').val();
  $.ajax({
    type: "POST",
    url: "/clients",
    data: {
      'client': { name: client }
    },
    dataType : 'json',
    success : function(data) {
      if(data.error) {
        $('#add-client .input').addClass('has-error');
        $('#project_client_name').after('<span class="help-inline">' + data.messages.name[0] + '</span>');
      } else {
        hideNewClientForm();
        $('#project_client_id option[value="-1"').remove();
        $('#project_client_id option[value="0"').remove();
        $('#project_client_id').append('<option value="' + data.id + '">' + data.name + '</option>');
        $('#project_client_id').val(data.id);
        $('#project_client_id').append('<option value="-1" disabled>──────────</option>');
        $('#project_client_id').append('<option value="0">Add a new client</option>');
        $('#project_task_ids').trigger('chosen:activate');
      }
    },
    error: function(msg) {
      removeClientErrors();
      $('#add-client .input').addClass('has-error');
      $('#project_client_name').after('<span class="help-inline">Connection refused</span>');
    }
  });
}

function disableForm() {
  disable_form_calls++;
  $('.form-actions .form-submit').attr('disabled','disabled');
}

function enableForm() {
  disable_form_calls--;
  if(disable_form_calls == 0) {
    $('.form-actions .form-submit').removeAttr('disabled');
  }
}
