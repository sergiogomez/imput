class DashboardController < ApplicationController
  include ClientFilling
  before_action :authorize_person, except: [:index]
  before_action :fill_clients
  before_action :create_ids_data, only: [:reports]
  before_action :create_r_data, only: [:reports]
  before_action :sanitize_params, only: [:run_reports]

  def index
    @person_time_calculator = PersonTimeDiffCalculator.new(current_person, Date.today)
    @person_time_calculator.process
    enabled_projects = current_person.projects.enabled
    @projects = enabled_projects.person_bigger(current_person)
    @max_time_project = current_person.company.projects.enabled.bigger.first.time_entered if @projects.size > 0

    if enabled_projects.size > 0
      clients_person_projects
      person_time_entry(enabled_projects)
    end
  end

  def run_reports
    redirect_to reports_path(@sanitized_params.time_frame_from,
                             @sanitized_params.time_frame_to,
                             @sanitized_params.clients,
                             @sanitized_params.projects,
                             @sanitized_params.tasks,
                             @sanitized_params.people)
  end

  def reports
    populate_time_frames
    @company = current_person.company
    @clients = current_person.clients_for_reports
    @projects = current_person.projects_for_reports
    time_frame_from = params[:time_frame_from]
    time_frame_to = params[:time_frame_to]

    if time_frame_from
      populate_ids_data("clients", @clients.ids.sort)
      populate_ids_data("projects", @projects.ids.sort)
      populate_ids_data("tasks", @company.tasks.ids.sort)
      populate_ids_data("people", @company.people.ids.sort)

      @time_entries = TimeEntry.joins(project: :client).where(spent_on: Date.parse(time_frame_from)..Date.parse(time_frame_to),
                                                              clients: {id: @ids_data.clients},
                                                              project: @ids_data.projects,
                                                              task: @ids_data.tasks,
                                                              person: @ids_data.people).where.not(hours: 0).order(spent_on: :asc)

      r_projects = Project.joins(:time_entries).distinct.where(time_entries: {id: @time_entries.ids})
      populate_r_data(r_projects,
                      Task.joins(:time_entries).distinct.where(time_entries: {id: @time_entries.ids}),
                      Client.joins(:projects).distinct.where(projects: {id: r_projects.ids}),
                      Person.joins(:projects).distinct.where(projects: {id: r_projects.ids}))

      @time_frame = "#{time_frame_from},#{time_frame_to}"
    end
    filename = "imputio_time_report_from_#{time_frame_from}_to_#{time_frame_to}"
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.xlsx\""
      }
      format.csv {
        send_data @time_entries.to_csv, filename: "#{filename}.csv"
      }
    end
  end

  private

  def authorize_person
    redirect_to root_path unless person_admin? or current_person.managed_projects.size > 0
  end

  def person_time_entry(enabled_projects)
    @time_entry = TimeEntry.new
    @time_entry.person_id = current_person.id
    @time_entry.spent_on = @selected_date
    last_time_entry =  current_person.last_time_entry
    if last_time_entry.nil?
      @time_entry.project = enabled_projects.first
      @time_entry.task = enabled_projects.first.tasks.first
    else
      @time_entry.project = last_time_entry.project
      @time_entry.task = last_time_entry.task
    end
  end

  def populate_time_frames
    @time_frames = []
    date_today = Date.today
    @time_frames << {label: :this_week, value: value_in_populate_time_frames(date_today, 'week')}
    @time_frames << {label: :last_week, value: value_in_populate_time_frames(date_today, 'week', 1)}

    @time_frames << {label: :this_month, value: value_in_populate_time_frames(date_today, 'month')}
    @time_frames << {label: :last_month, value: value_in_populate_time_frames(date_today, 'month', 1)}

    @time_frames << {label: :this_quarter, value: value_in_populate_time_frames(date_today, 'quarter')}
    @time_frames << {label: :last_quarter, value: value_in_populate_time_frames(date_today, 'quarter', 3)}

    @time_frames << {label: :this_year, value: value_in_populate_time_frames(date_today, 'year')}
    @time_frames << {label: :last_year, value: value_in_populate_time_frames(date_today, 'year', 1)}
  end

  def value_in_populate_time_frames(date_today, interval, amount = 0)
    case interval
      when 'week'
        (date_today - amount.week).beginning_of_week.strftime("%Y%m%d") + "," + ((date_today - amount.week).end_of_week).strftime("%Y%m%d")
      when 'month'
        (date_today - amount.month).beginning_of_month.strftime("%Y%m%d") + "," + ((date_today - amount.month).end_of_month).strftime("%Y%m%d")
      when 'quarter'
        (date_today - amount.month).beginning_of_quarter.strftime("%Y%m%d") + "," + ((date_today - amount.month).end_of_quarter).strftime("%Y%m%d")
      when 'year'
        (date_today - amount.year).beginning_of_year.strftime("%Y%m%d") + "," + ((date_today - amount.year).end_of_year).strftime("%Y%m%d")
    end
  end

  def populate_ids_data(what, sorted_ids)
    if params[what.to_sym] == 'any'
      @ids_data.send("#{what}=", sorted_ids)
    else
      @ids_data.send("#{what}=", params[what.to_sym].split('-').map(&:to_i) & sorted_ids)
    end
  end

  def populate_r_data(projects, tasks, clients, people)
    @r_data.projects = projects
    @r_data.tasks = tasks
    @r_data.clients = clients
    @r_data.people = people
  end

  def create_ids_data
    @ids_data = OpenStruct.new
  end

  def create_r_data
    @r_data = OpenStruct.new
  end

  def sanitize_params
    time_frame = params[:time_frame].split(',')
    @sanitized_params = OpenStruct.new
    @sanitized_params.time_frame_from = time_frame[0]
    @sanitized_params.time_frame_to = time_frame[1]
    @sanitized_params.clients = return_param(:clients)
    @sanitized_params.projects = return_param(:projects)
    @sanitized_params.tasks = return_param(:tasks)
    @sanitized_params.people = return_param(:people)
  end

  def return_param(param)
    params.key?(param) ? params[param].sort.join('-') : 'any'
  end
end
