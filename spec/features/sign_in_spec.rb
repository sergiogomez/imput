require 'rails_helper'

feature 'Sign In' do

  scenario 'Created user can sign in' do
    create_account # user@example.com password
    logout

    visit '/a/people/sign_in'

    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'

    expect(page).to have_text('Signed in successfully.')
  end

  scenario 'Not created user cannot sign in' do
    visit '/a/people/sign_in'

    fill_in 'Email', with: 'another@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'

    expect(page).to have_text('Invalid email address or password.')
  end

end