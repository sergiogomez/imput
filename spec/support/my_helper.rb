module MyHelper

  def create_account

    visit '/a/people/sign_up'

    fill_in 'Firstname', with: 'User'
    fill_in 'Lastname', with: 'Sample'
    fill_in 'Company', with: 'Company Inc.'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'

    click_button 'Register'
  end

  def create_employee
    visit '/en/people/new'

    fill_in 'Firstname', with: 'Employee'
    fill_in 'Lastname', with: 'Doe'
    fill_in 'Email', with: 'employee@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'

    click_button 'Create Person'
  end

  def assign_project_to_employee
    visit '/en/projects'

    click_link Person.last.company.projects.first.name

    select('Employee Doe', from: 'People')

    click_button 'Update Project'
  end

  def assign_project_manager_to_employee
    visit '/en/projects'

    click_link 'Project Managers'

    select('Employee Doe', from: 'People')

    click_button 'Update Project'
  end

  def create_another_client_and_project
    visit '/en/clients/new'

    fill_in 'Name', with: 'Second Client'

    click_button 'Create Client'

    visit '/en/projects/new'

    fill_in 'Name', with: 'Second Project'
    select('Second Client', from: 'Client')

    click_button 'Create Project'
  end 

  def logout
    # click_link 'User Sample'
    click_link 'Sign out'
  end

  def login_employee
    visit  '/a/people/sign_in'

    fill_in 'Email', with: 'employee@example.com'
    fill_in 'Password', with: 'password'

    click_button 'Sign in'
  end

end

RSpec.configure do |config|
  config.include MyHelper
end
