module DynamicSelect
  class TasksController < ApplicationController
    respond_to :json

    def index
      @project = Project.find_by(id: params[:project_id])
      @tasks = @project.tasks
      respond_with(@tasks)
    end

    def row
      @project = Project.find_by(id: params[:project_id])
      @tasks = []
      @project.tasks.each do |task|
        @tasks << task unless Row.find_by(person: current_person, project: @project, task: task, stored_at: params[:stored_at])
      end
      respond_with(@tasks)
    end

  end
end