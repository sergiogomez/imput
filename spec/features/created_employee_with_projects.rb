require 'rails_helper'

feature 'A created employee with projects' do
  background do
    create_account
    create_employee
    assign_project_to_employee
    logout
    login_employee
    @current_person = Person.last
    @first_project = @current_person.company.projects.first
    @first_task = @first_project.tasks.first
    @first_client = @current_person.company.clients.first
  end

  scenario 'can visit his dashboard' do
    visit '/dashboard'

    expect(page).to have_text('Daily')
    expect(page).not_to have_text('No Projects')
    expect(page).not_to have_text('Please, ask for a project to your boss... ;)')
  end

  scenario 'can visit his empty day time' do
    visit '/time/day'

    expect(page).to have_text(Date.today.strftime('%A %d %b'))
    expect(page).to have_text('There is no time entries')
    expect(page).not_to have_text('Start')
  end

  scenario 'can visit his empty week time' do
    visit '/time/week'

    expect(page).to have_text('There is no time entries')
    expect(page).not_to have_selector(:link_or_button, 'Save')
  end

  scenario 'cannot visit the company reports page' do
    visit '/reports'

    expect(page).not_to have_text('Reports')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the company projects page' do
    visit '/projects'

    expect(page).not_to have_text('Listing projects')
    expect(page).not_to have_text(@first_project.name)
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the company tasks page' do
    visit '/tasks'

    expect(page).not_to have_text('Listing tasks')
    expect(page).not_to have_text(@first_task.name)
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the company clients page' do
    visit '/clients'

    expect(page).not_to have_text('Listing clients')
    expect(page).not_to have_text(@first_client.name)
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the company people page' do
    visit '/people'

    expect(page).not_to have_text('Listing people')
    within(:css, ".main") do
      expect(page).not_to have_text(@current_person.fullname)
    end
    expect(page).not_to have_text('Admin')
    expect(page).to have_text('Daily')
  end

  scenario 'can visit the new time entry page' do
    visit "/time/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    expect(page).to have_text('Time entry')
    expect(page).to have_selector(:link_or_button, 'Start timer')
  end

  scenario 'can visit the add Project/Task Entry page' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    expect(page).to have_text("New Project/Task for week #{Date.today.cweek}")
    expect(page).to have_selector(:link_or_button, 'Save')
  end

  scenario 'cannot visit the new project page' do
    visit "/projects/new"

    expect(page).not_to have_selector(:link_or_button, 'Create Project')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the edit project page' do
    visit edit_project_url(@first_project)

    expect(page).not_to have_field('Name', @first_project.name)
    expect(page).not_to have_selector(:link_or_button, 'Update Project')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the new task page' do
    visit "/tasks/new"

    expect(page).not_to have_selector(:link_or_button, 'Create Task')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the edit task page' do
    visit edit_task_url(@first_task)

    expect(page).not_to have_field('Name', @first_task.name)
    expect(page).not_to have_selector(:link_or_button, 'Update Task')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the new client page' do
    visit "/clients/new"

    expect(page).not_to have_selector(:link_or_button, 'Create Client')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the edit client page' do
    visit edit_client_url(@first_client)

    expect(page).not_to have_field('Name', @first_client.name)
    expect(page).not_to have_selector(:link_or_button, 'Update Client')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the new person page' do
    visit "/people/new"

    expect(page).not_to have_selector(:link_or_button, 'Create Person')
    expect(page).to have_text('Daily')
  end

  scenario 'cannot visit the edit person page' do
    visit edit_person_url(@current_person)

    expect(page).not_to have_field('Firstname', @current_person.firstname)
    expect(page).not_to have_field('Lastname', @current_person.lastname)
    expect(page).not_to have_selector(:link_or_button, 'Update Person')
    expect(page).to have_text('Daily')
  end

  scenario 'can visit his profile page' do
    visit '/profile'

    expect(page).to have_field('Firstname', @current_person.firstname)
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

  scenario 'cannot visit the company account page' do
    visit '/account'

    expect(page).not_to have_text('Member since')
    expect(page).not_to have_text(Date.today.strftime('%B %d, %Y'))
    expect(page).to have_text('Daily')
  end

  scenario 'can create a new time entry for today' do
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

  scenario 'can create a new timer for today' do
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

  scenario 'can create a project/task entry for this week' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    click_button 'Save'

    expect(page).to have_text("Week ##{Date.today.cweek}")
    expect(page).to have_text("#{@first_client.name}: #{@first_project.name} - #{@first_task.name}")
    expect(page).to have_selector(:link_or_button, 'Save')
  end

  scenario 'cannot create a duplicated project/task entry for this week' do
    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"

    select(@first_project.name, from: 'Project')
    select(@first_task.name, from: 'Task')
    click_button 'Save'

    visit "/time/week/new/#{Date.today.year}/#{Date.today.month}/#{Date.today.day}"
    select('Internal', from: 'Project')

    expect(page).not_to have_text(@first_task.name)
  end

  scenario 'cannot create more project/task entry for this week when they are all created' do
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

  scenario 'can edit his profile' do
    visit '/profile'

    fill_in 'Firstname', with: 'Renamed'

    click_button 'Update Person'

    expect(page).to have_field('Firstname', "Renamed")
    expect(page).to have_field('Lastname', @current_person.lastname)
    expect(page).to have_selector(:link_or_button, 'Update Person')
  end

end