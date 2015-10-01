class PeopleController < ApplicationController
  before_action :authorize_person!, except: [:profile, :update, :switch_time_format]
  before_action :set_person, only: [:show, :edit, :update, :destroy, :disable, :enable]
  skip_before_filter :require_no_authentication

  # GET /people
  def index
    @people = current_person.company.people
    respond_to do |format|
      format.html
      format.xlsx
      format.csv { send_data @people.to_csv }
    end
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # GET /profile
  def profile
    @person = current_person
    render :edit
  end

  # POST /people
  def create
    @person = Person.new(person_params)
    @person.company = current_person.company
    @person.company_name = current_person.company.name # For validation purpose

    respond_to do |format|
      if @person.save
        format.html { redirect_to people_url, notice: 'Person was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /people/1
  def update
    current_id = current_person.id
    if params[:person][:password].blank? && params[:person][:password_confirmation].blank?
      params[:person].delete(:password)
      params[:person].delete(:password_confirmation)
    end
    respond_to do |format|
      if @person.update(person_params)
        sign_in(Person.find(current_id), :bypass => true)
        format.html { redirect_to request.referer, notice: 'Person was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /people/1
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
    end
  end

  # GET /people/import
  def import
  end

  # POST /people/import
  def import_file
    success, errors = Person.import(current_person, params[:file])
    flash[:notice] = success.join('<br />') if success.size > 0
    flash[:error] = errors.join('<br />') if errors.size > 0
    redirect_to people_url
  end

  # PATCH /switch_time_format
  def switch_time_format
    current_person.time_decimal = !current_person.time_decimal
    current_person.save
    redirect_to request.referer
  end

  # PATCH /people/1/disable
  def disable
    @person.enabled = false
    @person.save
    redirect_to request.referer
  end

  # PATCH /people/1/enable
  def enable
    @person.enabled = true
    @person.save
    redirect_to request.referer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = current_person.company.people.find_by(id: params[:id])
      redirect_to root_path if @person.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:firstname, :lastname, :email, :password, :password_confirmation, :notes, :admin, :receive_daily_report, :time_decimal, :max_hours)
    end

    def authorize_person!
      redirect_to root_path unless person_admin?
    end

end
