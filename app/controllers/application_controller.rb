class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |controller| controller.request.format.json? }

  # This is our new function that comes before Devise's one
  before_filter :authenticate_person_from_token!
  # This is Devise's authentication
  before_filter :authenticate_person!
  before_action :set_locale



  helper_method :person_admin?

  def person_admin?
    current_person.admin
  end

  private

    def authenticate_person_from_token!
      person_email = request.headers["X-Person-Email"].presence
      person       = person_email && Person.find_by_email(person_email)

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if person && Devise.secure_compare(person.authentication_token, request.headers["X-Person-Token"])
        sign_in person, store: false
      end
    end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
