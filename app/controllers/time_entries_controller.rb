class TimeEntriesController < ApplicationController
  include ClientFilling
  before_action :authorize_person!
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy, :start, :stop, :duplicate]
  before_action :get_clients, only: [:new, :create, :edit, :update]
  before_action :get_selected_date, only: [:new, :create, :edit, :update]
  before_action :round_hours, only: [:create, :update]

  # GET /time_entries
  def index
    @time_entries = current_person.time_entries.where(spent_on: Date.today)
    respond_to do |format|
      format.json { render :json => custom_json_for(@time_entries) }
    end
  end

  # GET /time_entries/1
  def show
    respond_to do |format|
      format.json { render :json => custom_json_for([@time_entry]) }
    end
  end

  # GET /time/new/:year/:month/:day
  def new
    @time_entry = TimeEntry.new
    @time_entry.person_id = current_person.id
    @time_entry.spent_on = @selected_date
    if current_person.last_time_entry.nil?
      @time_entry.project = current_person.projects.first
      @time_entry.task = current_person.projects.first.tasks.first
    else
      @time_entry.project = current_person.last_time_entry.project
      @time_entry.task = current_person.last_time_entry.task
    end
  end

  # GET /time_entries/1/edit
  def edit
  end

  # POST /time_entries
  def create
    @time_entry = TimeEntry.new(time_entry_params)
    @time_entry.person_id = current_person.id
    @time_entry.spent_on = @selected_date

    if @time_entry.save
      respond_to do |format|
        format.html {
          if params[:from] == 'dashboard'
            redirect_to dashboard_url
          else
            redirect_to time_day_url(@selected_date.year,@selected_date.month,@selected_date.day)
          end
        }
        format.json { render :json => custom_json_for([@time_entry]) }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render :json => custom_json_for([@time_entry]) }
      end
    end
  end

  # PATCH/PUT /time_entries/1
  def update
    if @time_entry.update(time_entry_params)
      if params[:from] == 'dashboard'
        redirect_to dashboard_url
      else
        redirect_to time_day_url(@selected_date.year,@selected_date.month,@selected_date.day)
      end
    else
      render :edit
    end
  end

  # DELETE /time_entries/1
  def destroy
    year = @time_entry.spent_on.year
    month = @time_entry.spent_on.month
    day = @time_entry.spent_on.day
    @time_entry.destroy
    respond_to do |format|
      format.html { redirect_to time_day_url(year,month,day) }
    end
  end

  # PATCH/PUT /time_entries/1/start
  def start
    stopped_time_entry_id = current_person.current_time_entry.id unless current_person.current_time_entry.nil?
    @time_entry.start
    respond_to do |format|
      if @time_entry.save
        @stopped_time_entry = current_person.time_entries.find_by(id: stopped_time_entry_id) unless stopped_time_entry_id.nil?
        format.html { redirect_to request.referer }
        format.js
        format.json { render :json => custom_json_for([@time_entry]) }
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  # PATCH/PUT /time_entries/1/stop
  def stop
    @time_entry.stop
    respond_to do |format|
      if @time_entry.save
        format.html { redirect_to request.referer }
        format.js
        format.json { render :json => custom_json_for([@time_entry]) }
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  # PATCH/PUT /time_entries/1/duplicate
  def duplicate
    @new_time_entry = @time_entry.duplicate_and_start
    respond_to do |format|
      if @new_time_entry.save
        format.html { redirect_to request.referer }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

   # GET /time_entries/import
  def import
  end

  # POST /time_entries/import
  def import_file
    success, errors, time_entries = TimeEntry.import(current_person, params[:file])
    flash[:notice] = "Time entries imported: #{time_entries}"
    flash[:notice] = flash[:notice] + '<br />' + success.join('<br />') if success.size > 0
    flash[:error] = errors.join('<br />') if errors.size > 0
    redirect_to imports_url
  end

 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_entry
      @time_entry = current_person.time_entries.find_by(id: params[:id])
      redirect_to root_path if @time_entry.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_entry_params
      params.require(:time_entry).permit(:hours, :spent_on, :begun_on, :project_id, :task_id, :notes)
    end

    def get_clients
      fill_clients
      clients_person_projects
    end

    def get_selected_date
      if params[:year]
        @selected_date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
      elsif !@time_entry.nil?
        @selected_date = @time_entry.spent_on
      else
        @selected_date = Date.today
      end
    end

    def round_hours
      params[:time_entry][:hours] = params[:time_entry][:hours].to_f.round(2) unless params[:time_entry][:hours] == ""
    end

    def authorize_person!
      redirect_to root_path unless current_person.projects.size > 0
    end

    def custom_json_for(value)
      list = value.map do |time_entry|
        {
          data: time_entry,
          project_name: time_entry.project.name,
          task_name: time_entry.task.name,
          client_name: time_entry.project.client.name
        }
      end
      list.to_json
    end

end
