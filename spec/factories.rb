FactoryGirl.define do
  factory :reminder do
    text ""
    notify_at ""
    job_id 1
  end

  factory :person do
    firstname 'User'
    lastname 'Sample'
    company_name 'Company Inc.'
    email 'user@example.com'
    password 'password'
  end
end
