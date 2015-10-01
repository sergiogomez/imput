class TasksController < ApplicationController
  before_action :authorize_person!
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  def index
    @tasks = current_person.company.tasks
    @grouped_tasks = current_person.company.grouped_tasks
    respond_to do |format|
      format.html
      format.xlsx
      format.csv { send_data @tasks.to_csv }
    end
  end

  # GET /projects/1/tasks/1
  def show
    respond_to do |format|
      format.json { render json: { project: current_person.projects.find_by(id: params[:project_id]), task: @task } }
    end
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @task.company = current_person.company

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_url, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created }
      else
        format.html { render :new }
        format.json { render json: {error: true, messages: @task.errors } }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_url, notice: 'Task was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
    end
  end

  # GET /tasks/import
  def import
  end

  # POST /tasks/import
  def import_file
    success, errors = Task.import(current_person, params[:file])
    flash[:notice] = success.join('<br />') if success.size > 0
    flash[:error] = errors.join('<br />') if errors.size > 0
    redirect_to tasks_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = current_person.company.tasks.find_by(id: params[:id])
      redirect_to root_path if @task.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:name, :notes, :common, :project_ids => [])
    end

    def authorize_person!
      redirect_to root_path unless person_admin? or current_person.managed_projects.size > 0
    end

end
