class RegistrationsController < Devise::RegistrationsController
  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:firstname, :lastname, :company_name, :email, :password, :password_confirmation)}
    # devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password)}
  end

  def create
    super
    seed_company if resource.save
  end

  private

    def seed_company
      company = Company.create!(name: resource.company_name)
      resource.company = company
      resource.admin = true
      resource.save
      client = Client.create!(name: resource.company_name, company: company)
      Task.create!(name: "Development", company: company, common: true)
      Task.create!(name: "Management", company: company, common: true)
      Task.create!(name: "Meetings", company: company, common: true)
      Task.create!(name: "Support", company: company, common: true)
      Task.create!(name: "Vacation", company: company, common: true)
      project = Project.create!(name: "Internal", company: company, client: client, tasks: company.common_tasks, people: company.people)
    end

end
