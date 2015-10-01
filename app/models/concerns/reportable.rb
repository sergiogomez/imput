module Reportable
  extend ActiveSupport::Concern

  included do
  end

  def handle_params(from, to, clients, projects, tasks, people, current_person)
    if current_person.admin?
      @clients = current_person.company.clients
      @projects = current_person.company.projects
    elsif current_person.managed_projects.size > 0
      @clients = current_person.managed_clients
      @projects = current_person.managed_projects
    end
    @tasks = current_person.company.tasks
    @people = current_person.company.people

    if clients == "any"
      @clients_ids = @clients.ids.sort
    else
      @clients_ids = clients.split('-').map(&:to_i) & @clients.ids.sort
    end
    if projects == "any"
      @projects_ids = @projects.ids.sort
    else
      @projects_ids = projects.split('-').map(&:to_i) & @projects.ids.sort
    end
    if tasks == "any"
      @tasks_ids = @tasks.ids.sort
    else
      @tasks_ids = tasks.split('-').map(&:to_i) & @tasks.ids.sort
    end
    if people == "any"
      @people_ids = @people.ids.sort
    else
      @people_ids = people.split('-').map(&:to_i) & @people.ids.sort
    end
  end

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods

  end

end