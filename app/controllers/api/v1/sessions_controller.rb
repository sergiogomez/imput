class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :check_trial!

  def create
    resource = Person.find_for_database_authentication(
      email: params[:person_email]
    )

    if resource.valid_password?(params[:person_password])
      render json: {
        success: true,
        auth_token: resource.renew_authentication_token,
        email: resource.email
      }
      return
    end
    return render json: { success: false }
  end

end
