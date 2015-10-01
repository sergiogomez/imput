class RowsController < ApplicationController
  include ClientFilling
  before_action :authorize_person!
  before_action :set_row, only: [:destroy]

  # GET /time/week/new
  def new
    @row = Row.new
    @row.person_id = current_person.id
    @row.stored_at = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i).beginning_of_week
    @rows = current_person.rows.where(stored_at: @row.stored_at..@row.stored_at.beginning_of_week)
    
    @clients = []
    @projects = []
    
    current_person.projects.enabled.each do |project|
      available_tasks = []
      project.tasks.each do |task|
        available_tasks << task unless Row.find_by(person: current_person, project: project, task: task, stored_at: @row.stored_at)
      end
      if available_tasks.size > 0
        project.available_tasks = available_tasks
        @projects << project
        @clients << project.client unless @clients.include? project.client
      end
    end

    clients_person_projects

    @tasks = current_person.tasks
    @row.project = @projects.first
    @row.task = @row.project.tasks.first
    if !current_person.last_time_entry.nil?
      if @projects.include? current_person.last_time_entry.project
        @row.project = @projects[@projects.index(current_person.last_time_entry.project)]
      end
      if @row.project.available_tasks.include? current_person.last_time_entry.task
        @row.task = current_person.last_time_entry.task
      end        
    end

    redirect_to time_week_url(params[:year],params[:month],params[:day]), notice: 'No more rows!!' if @clients.size == 0
  end

  # POST /rows
  def create
    @row = Row.new(row_params)
    @row.person_id = current_person.id
    @row.stored_at = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i).beginning_of_week

    respond_to do |format|
      if @row.save
        format.html { redirect_to time_week_url(params[:year],params[:month],params[:day]) }
        format.json { render :show, status: :created, location: @row }
      else
        format.html { render :new }
        format.json { render json: @row.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rows/1
  def destroy
    year = @row.stored_at.year
    month = @row.stored_at.month
    day = @row.stored_at.day
    @row.destroy
    respond_to do |format|
      format.html { redirect_to time_week_url(year,month,day) }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_row
      @row = current_person.rows.find_by(id: params[:id])
      redirect_to root_path if @row.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def row_params
      params.require(:row).permit(:project_id, :task_id)
    end

    def authorize_person!
      redirect_to root_path unless current_person.projects.enabled.size > 0
    end

end
