class CompaniesController < ApplicationController
  before_action :authorize_person!
  before_action :set_company, only: [:show, :destroy]

  # GET /account
  def show
  end

  # DELETE /delete_account
  def destroy
    @company.destroy
    redirect_to root_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = current_person.company
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :notes)
    end

    def authorize_person!
      redirect_to root_path unless person_admin?
    end

end
