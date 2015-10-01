class ProjectsController < ApplicationController
  before_action :authorize_person!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :edit_project_managers, :disable, :enable]

  # GET /projects
  def index
    if current_person.admin?
      @clients = current_person.company.clients.enabled
      @projects = current_person.company.projects
    elsif current_person.managed_projects.size > 0
      @clients = current_person.managed_clients.enabled.order(name: :asc)
      @projects = current_person.managed_projects
    end
    respond_to do |format|
      format.html
      format.xlsx
      format.csv { send_data @projects.to_csv }
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  def show
    respond_to do |format|
      format.json { render json: { project: @project, tasks: @project.tasks } }
    end
  end

  # GET /projects/new
  def new
    if current_person.admin?
      @project = Project.new
      @project.company = current_person.company
      @project.tasks = @project.company.common_tasks
      @project.people << current_person
      @client = Client.new
    else
      redirect_to projects_url
    end
  end

  # GET /projects/1/edit
  def edit
    @client = Client.new
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.company = current_person.company

    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_url, notice: 'Project was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  def update
    if project_params["project_manager_ids"]
      @project.members.each do |member|
        if project_params["project_manager_ids"].include? member.person.id.to_s
          member.project_manager = true
        else
          member.project_manager = false
        end
        member.save
      end
      redirect_to projects_url
    else
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to projects_url, notice: 'Project was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
    end
  end

  # GET /projects/import
  def import
  end

  # POST /projects/import
  def import_file
    success, errors = Project.import(current_person, params[:file])
    flash[:notice] = success.join('<br />') if success.size > 0
    flash[:error] = errors.join('<br />') if errors.size > 0
    redirect_to projects_url
  end

  # GET /projects/1/project_managers
  def edit_project_managers
    redirect_to projects_url unless person_admin?
  end

  # PATCH /projects/1/disable
  def disable
    if !current_person.current_time_entry.nil?
      current_person.current_time_entry.stop
      current_person.current_time_entry = nil
    end
    @project.enabled = false
    @project.save
    redirect_to request.referer
  end

  # PATCH /projects/1/enable
  def enable
    @project.enabled = true
    @project.save
    redirect_to request.referer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_person.company.projects.find_by(id: params[:id])
      redirect_to root_path if @project.nil?
      redirect_to projects_url unless person_admin? or current_person.managed_projects.include? @project
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :notes, :client_id, :task_ids => [], :person_ids => [], :project_manager_ids => [])
    end

    def authorize_person!
      redirect_to root_path unless person_admin? or current_person.managed_projects.size > 0
    end

end
