module ClientFilling
  extend ActiveSupport::Concern

  def fill_clients
    @clients = []

    current_person.clients.enabled.each do |client|
      client.projects.enabled.each do |project|
        if current_person.projects.enabled.include? project
          @clients << project.client unless @clients.include? project.client
        end
      end
    end
  end

  def clients_person_projects
    @clients.each do |client|
      person_projects = []
      client.projects.enabled.each do |project|
        person_projects << project if current_person.projects.enabled.include? project
      end
      client.person_projects = person_projects
    end
  end

end
