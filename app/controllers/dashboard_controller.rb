class DashboardController < ApplicationController
  include ClientFilling
  before_action :authorize_person!, except: [:index]

  def index
    @hours_today = TimeEntry.day_time(current_person, Date.today)
    @hours_yesterday = TimeEntry.day_time(current_person, Date.today - 1)
    @diff_hours_today = (@hours_today - @hours_yesterday).round(2)

    @hours_this_week = TimeEntry.week_total_time(current_person, Date.today.beginning_of_week)
    @hours_last_week = TimeEntry.week_total_time(current_person, (Date.today - 7).beginning_of_week)
    @diff_hours_this_week = (@hours_this_week - @hours_last_week).round(2)

    @hours_this_month = TimeEntry.month_total_time(current_person, Date.today)
    @hours_last_month = TimeEntry.month_total_time(current_person, Date.today - 1.month)
    @diff_hours_this_month = (@hours_this_month - @hours_last_month).round(2)

    @hours_this_quarter = TimeEntry.quarter_total_time(current_person, Date.today)
    @hours_last_quarter = TimeEntry.quarter_total_time(current_person, Date.today - 3.month)
    @diff_hours_this_quarter = (@hours_this_quarter - @hours_last_quarter).round(2)

    @projects = current_person.projects.enabled.person_bigger(current_person)
    @max_time_project = current_person.company.projects.enabled.bigger.first.time_entered if @projects.size > 0

    @current_time_entry = current_person.current_time_entry || current_person.dashboard_last_time_entry

    # Copied from time_entries_controller.rb

    fill_clients

    if current_person.projects.enabled.size > 0

      clients_person_projects

      @time_entry = TimeEntry.new
      @time_entry.person_id = current_person.id
      @time_entry.spent_on = @selected_date
      if current_person.last_time_entry.nil?
        @time_entry.project = current_person.projects.enabled.first
        @time_entry.task = current_person.projects.enabled.first.tasks.first
      else
        @time_entry.project = current_person.last_time_entry.project
        @time_entry.task = current_person.last_time_entry.task
      end

    end
  end

  def run_reports
    time_frame_from = params[:time_frame].split(',')[0]
    time_frame_to = params[:time_frame].split(',')[1]
    clients = params[:clients].nil? ? "any" : params[:clients].sort.join('-')
    projects = params[:projects].nil? ? "any" : params[:projects].sort.join('-')
    tasks = params[:tasks].nil? ? "any" : params[:tasks].sort.join('-')
    people = params[:people].nil? ? "any" : params[:people].sort.join('-')
    redirect_to reports_path(time_frame_from, time_frame_to, clients, projects, tasks, people)
  end

  def reports
    @time_frames = []
    @time_frames << { label: "This week", value: "#{Date.today.beginning_of_week.strftime("%Y%m%d")},#{(Date.today.end_of_week).strftime("%Y%m%d")}" }
    @time_frames << { label: "Last week", value: "#{(Date.today - 1.week).beginning_of_week.strftime("%Y%m%d")},#{((Date.today - 1.week).end_of_week).strftime("%Y%m%d")}" }
    @time_frames << { label: "This month", value: "#{Date.today.beginning_of_month.strftime("%Y%m%d")},#{(Date.today.end_of_month).strftime("%Y%m%d")}" }
    @time_frames << { label: "Last month", value: "#{(Date.today - 1.month).beginning_of_month.strftime("%Y%m%d")},#{((Date.today - 1.month).end_of_month).strftime("%Y%m%d")}" }
    @time_frames << { label: "This quarter", value: "#{Date.today.beginning_of_quarter.strftime("%Y%m%d")},#{(Date.today.end_of_quarter).strftime("%Y%m%d")}" }
    @time_frames << { label: "Last quarter", value: "#{(Date.today - 3.month).beginning_of_quarter.strftime("%Y%m%d")},#{((Date.today - 3.month).end_of_quarter).strftime("%Y%m%d")}" }
    @time_frames << { label: "This year", value: "#{Date.today.beginning_of_year.strftime("%Y%m%d")},#{(Date.today.end_of_year).strftime("%Y%m%d")}" }
    @time_frames << { label: "Last year", value: "#{(Date.today - 1.year).beginning_of_year.strftime("%Y%m%d")},#{((Date.today - 1.year).end_of_year).strftime("%Y%m%d")}" }

    if current_person.admin?
      @clients = current_person.company.clients
      @projects = current_person.company.projects
    elsif current_person.managed_projects.size > 0
      @clients = current_person.managed_clients
      @projects = current_person.managed_projects
    end
    @tasks = current_person.company.tasks
    @people = current_person.company.people

    if params[:time_frame_from]
      if params[:clients] == "any"
        @clients_ids = @clients.ids.sort
      else
        @clients_ids = params[:clients].split('-').map(&:to_i) & @clients.ids.sort
      end
      if params[:projects] == "any"
        @projects_ids = @projects.ids.sort
      else
        @projects_ids = params[:projects].split('-').map(&:to_i) & @projects.ids.sort
      end
      if params[:tasks] == "any"
        @tasks_ids = @tasks.ids.sort
      else
        @tasks_ids = params[:tasks].split('-').map(&:to_i) & @tasks.ids.sort
      end
      if params[:people] == "any"
        @people_ids = @people.ids.sort
      else
        @people_ids = params[:people].split('-').map(&:to_i) & @people.ids.sort
      end
      @time_entries = TimeEntry.joins(project: :client).where(spent_on: Date.parse(params[:time_frame_from])..Date.parse(params[:time_frame_to]), clients: { id: @clients_ids }, project: @projects_ids, task: @tasks_ids, person: @people_ids).where.not(hours: 0).order(spent_on: :asc)

      @r_projects = Project.joins(:time_entries).distinct.where(time_entries: { id: @time_entries.ids })
      @r_tasks = Task.joins(:time_entries).distinct.where(time_entries: { id: @time_entries.ids })
      @r_clients = Client.joins(:projects).distinct.where(projects: { id: @r_projects.ids })
      @r_people = Person.joins(:projects).distinct.where(projects: { id: @r_projects.ids })

      @time_frame = params[:time_frame_from] + "," + params[:time_frame_to]
      @clients_ids = nil if params[:clients] == "any"
      @projects_ids = nil if params[:projects] == "any"
      @tasks_ids = nil if params[:tasks] == "any"
      @people_ids = nil if params[:people] == "any"
    end
    filename = "imputio_time_report_from_#{params[:time_frame_from]}_to_#{params[:time_frame_to]}"
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

    def authorize_person!
      redirect_to root_path unless person_admin? or current_person.managed_projects.size > 0
    end

end
