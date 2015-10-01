require 'rails_helper'

feature 'A created person (and admin) can' do
  background do
    create_account
    @current_person = Person.last
    @first_project = @current_person.company.projects.first
    @first_task = @first_project.tasks.first
    @first_client = @current_person.company.clients.first
  end

  scenario 'visit his dashboard' do
    visit '/dashboard'

    expect(page).to have_text('Daily')
  end

  scenario 'visit his empty day time' do
    visit '/time/day'

    expect(page).to have_text(Date.today.strftime('%A %d %b'))
    expect(page).to have_text('There is no time entries')
    expect(page).not_to have_text('Start')
  end

  scenario 'visit his empty week time' do
    visit '/time/week'

    expect(page).to have_text('There is no time entries')
    expect(page).not_to have_selector(:link_or_button, 'Save')
  end

  scenario 'visit the company reports page' do
    visit '/reports'

    expect(page).to have_text('Reports')
  end

  scenario 'visit the company projects page' do
    visit '/projects'

    expect(page).to have_text('Listing projects')
    expect(page).to have_text(@first_project.name)
  end

  scenario 'visit the company tasks page' do
    visit '/tasks'

    expect(page).to have_text('Listing tasks')
    expect(page).to have_text(@first_task.name)
  end

  scenario 'visit the company clients page' do
    visit '/clients'

    expect(page).to have_text('Listing clients')
    expect(page).to have_text(@first_client.name)
  end

  scenario 'visit the company people page' do
    visit '/people'

    expect(page).to have_text('Listing people')
    within(:css, ".main") do
      expect(page).to have_text(@current_person.fullname)
    end
    expect(page).to have_text('Admin')
  end

  scenario 'visit the new time entry page' do
    visit "/time/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    expect(page).to have_text('Time entry')
    expect(page).to have_selector(:link_or_button, 'Start timer')
  end

  scenario 'visit the add Project/Task Entry page' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    expect(page).to have_text("New Project/Task for week #{Date.today.cweek}")
    expect(page).to have_selector(:link_or_button, 'Save')
  end

  scenario 'visit the new project page' do
    visit "/projects/new"

    expect(page).to have_selector(:link_or_button, 'Create Project')
  end

  scenario 'visit the edit project page' do
    visit edit_project_url(@first_project)

    expect(page).to have_field('Name', @first_project.name)
    expect(page).to have_selector(:link_or_button, 'Update Project')
  end

  scenario 'visit the Project Managers project page' do
    visit edit_project_managers_url(@first_project)

    expect(page).to have_text("Select Project Managers for")
    expect(page).to have_field('People', '')
    expect(page).to have_selector(:link_or_button, 'Update Project')
  end

  scenario 'visit the new task page' do
    visit "/tasks/new"

    expect(page).to have_selector(:link_or_button, 'Create Task')
  end

  scenario 'visit the edit task page' do
    visit edit_task_url(@first_task)

    expect(page).to have_field('Name', @first_task.name)
    expect(page).to have_selector(:link_or_button, 'Update Task')
  end

  scenario 'visit the new client page' do
    visit "/clients/new"

    expect(page).to have_selector(:link_or_button, 'Create Client')
  end

  scenario 'visit the edit client page' do
    visit edit_client_url(@first_client)

    expect(page).to have_field('Name', @first_client.name)
    expect(page).to have_selector(:link_or_button, 'Update Client')
  end

  scenario 'visit the new person page' do
    visit "/people/new"

    expect(page).to have_selector(:link_or_button, 'Create Person')
  end

  scenario 'visit the edit person page' do
    visit edit_person_url(@current_person)

    expect(page).to have_field('Firstname', @current_person.firstname)
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

  scenario 'visit his profile page' do
    visit '/profile'

    expect(page).to have_field('Firstname', @current_person.firstname)
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

  scenario 'visit the company account page' do
    visit '/account'
    expect(page).to have_text('Account Settings')
  end

  scenario 'create a new time entry for today' do
    visit "/time/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    fill_in 'Hours', with: '7'
    click_button 'Start timer'

    expect(page).to have_text(Date.today.strftime('%A %d %b'))
    expect(page).to have_text("#{@first_project.name} (#{@first_client.name})")
    expect(page).to have_text(@first_task.name)
    expect(page).to have_text('7.0')
    expect(page).to have_text('Start')
    expect(page).not_to have_text('Stop')
  end

  scenario 'create a new timer for today' do
    visit "/time/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    click_button 'Start timer'

    expect(page).to have_text(Date.today.strftime('%A %d %b'))
    expect(page).to have_text("#{@first_project.name} (#{@first_client.name})")
    expect(page).to have_text(@first_task.name)
    expect(page).not_to have_text('Start')
    expect(page).to have_text('Stop')
  end

  scenario 'create a project/task entry for this week' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    click_button 'Save'

    expect(page).to have_text("Week ##{Date.today.cweek}")
    expect(page).to have_text("#{@first_client.name}: #{@first_project.name} - #{@first_task.name}")
    expect(page).to have_selector(:link_or_button, 'Save')
  end

  scenario 'not create a duplicated project/task entry for this week' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    click_button 'Save'

    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"
    select('Internal', from: 'Project')

    expect(page).not_to have_text(@first_task.name)
  end

  scenario 'not create more project/task entry for this week when they are all created' do
    @current_person.projects.each do |project|
      project.tasks.each do |task|
        visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

        select(project.name, from: 'Project')
        select(task.name, from: 'Task')
        click_button 'Save'
      end
    end

    @current_person.projects.each do |project|
      project.tasks.each do |task|
        expect(page).to have_text("#{project.company.name}: #{project.name} - #{task.name}")
      end
    end

    expect(page).to have_text("Week ##{Date.today.cweek}")
    expect(page).not_to have_text('Add Project/Task Entry')
    expect(page).to have_selector(:link_or_button, 'Save')
  end

  scenario 'run a complete but empty report' do
    visit "/reports"

    click_button 'Run Report'

    expect(page).to have_text('Time Entries')
    expect(page).to have_text('There are no time entries with the selected parameters.')
  end

  scenario 'run a complete with time entries' do
    visit "/time/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    fill_in 'Hours', with: '7'
    click_button 'Start timer'

    visit "/reports"

    click_button 'Run Report'

    expect(page).to have_text('Time Entries')
    expect(page).to have_text(@first_client.name)
    expect(page).to have_text(@first_project.name)
    expect(page).to have_text(@first_task.name)
    expect(page).to have_text('Total')
    expect(page).to have_text('7.0')
    expect(page).not_to have_text('There are no time entries with the selected parameters.')
  end

  scenario 'create a new project' do
    visit '/projects/new'

    fill_in 'Name', with: 'Sample project'

    click_button 'Create Project'

    expect(page).to have_text('Listing projects')
    expect(page).to have_text(@first_project.name)
    expect(page).to have_text('Sample project')
  end

  scenario 'edit a project' do
    visit edit_project_url(@first_project)

    fill_in 'Name', with: 'Renamed project'

    click_button 'Update Project'

    expect(page).to have_text('Listing projects')
    expect(page).not_to have_text(@first_project.name)
    expect(page).to have_text('Renamed project')
  end

  scenario 'create a new task' do
    visit '/tasks/new'

    fill_in 'Name', with: 'Sample task'

    click_button 'Create Task'

    expect(page).to have_text('Listing tasks')
    expect(page).to have_text(@first_task.name)
    expect(page).to have_text('Sample task')
  end

  scenario 'edit a task' do
    visit edit_task_url(@first_task)

    fill_in 'Name', with: 'Renamed task'

    click_button 'Update Task'

    expect(page).to have_text('Listing tasks')
    expect(page).not_to have_text(@first_task.name)
    expect(page).to have_text('Renamed task')
  end

  scenario 'create a new client' do
    visit '/clients/new'

    fill_in 'Name', with: 'Sample client'

    click_button 'Create Client'

    expect(page).to have_text('Listing clients')
    expect(page).to have_text(@first_client.name)
    expect(page).to have_text('Sample client')
  end

  scenario 'edit a client' do
    visit edit_client_url(@first_client)

    fill_in 'Name', with: 'Renamed client'

    click_button 'Update Client'

    expect(page).to have_text('Listing clients')
    expect(page).not_to have_text(@first_client.name)
    expect(page).to have_text('Renamed client')
  end

  scenario 'create a new person' do
    visit '/people/new'

    fill_in 'Firstname', with: 'New User'
    fill_in 'Lastname', with: 'Sample 2'
    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'

    click_button 'Create Person'

    expect(page).to have_text('Listing people')
    within(:css, ".main") do
      expect(page).to have_text(@current_person.fullname)
    end
    expect(page).to have_text('New User Sample 2')
  end

  scenario 'edit a person' do
    visit edit_person_url(@current_person)

    fill_in 'Firstname', with: 'Renamed'

    click_button 'Update Person'

    expect(page).not_to have_text('Listing people')
    expect(page).to have_field('Firstname', "Renamed")
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

  scenario 'can edit his profile' do
    visit '/profile'

    fill_in 'Firstname', with: 'Renamed'

    click_button 'Update Person'

    expect(page).to have_field('Firstname', "Renamed")
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

end