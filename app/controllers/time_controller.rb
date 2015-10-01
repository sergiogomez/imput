class TimeController < ApplicationController
  before_action :authorize_person!
  before_action :get_selected_date

  # GET /time/week/:year/:month/:day
  def week
    @time_entry = TimeEntry.new
    projects_enabled_ids = current_person.company.projects.enabled.ids
    projects_disabled_ids = current_person.company.projects.disabled.ids
    @disabled_rows = Row.where(person: current_person, stored_at: @selected_date.beginning_of_week..@selected_date.beginning_of_week+6, project: projects_disabled_ids)
    @rows = Row.where(person: current_person, stored_at: @selected_date.beginning_of_week..@selected_date.beginning_of_week+6, project: projects_enabled_ids)
  end

  # PATCH/PUT /time/week/:year/:month/:day
  def update
    @rows = Row.where(person: current_person, stored_at: @selected_date.beginning_of_week..@selected_date.beginning_of_week+6)
    @rows.each do |row|
      (0..6).each do |n|
        hours = params["day#{n}_project#{row.project.id}_task#{row.task.id}"].to_f
        if !params["day#{n}_project#{row.project.id}_task#{row.task.id}"].nil?
          TimeEntry.adjust_time_entry(current_person, @selected_date.beginning_of_week + n, row.project, row.task, hours)
        end
      end
    end
    redirect_to time_week_path(params[:year],params[:month],params[:day]), notice: 'Timesheet was successfully updated.'
  end

  # GET /time/day/:year/:month/:day
  def day
    @time_entry = TimeEntry.new
    @time_entries = current_person.time_entries.where(spent_on: @selected_date)
    if current_person.current_time_entry
      @spent_on = current_person.current_time_entry.spent_on
    else
      @spent_on = ''
    end
  end

  # PATCH/PUT /time/day/duplicate/:year/:month/:day
  def duplicate_day
    current_person.last_day_time_entries.each do |time_entry|
      new_time_entry = time_entry.duplicate
      new_time_entry.spent_on = @selected_date
      new_time_entry.save
    end
    redirect_to time_day_url(@selected_date.year,@selected_date.month,@selected_date.day)
  end

  # PATCH/PUT /time/week/duplicate/:year/:month/:day
  def duplicate_row
    current_person.last_week_rows.each do |row|
      new_row = row.duplicate
      new_row.stored_at = @selected_date.beginning_of_week
      new_row.save
    end
    redirect_to time_week_url(@selected_date.year,@selected_date.month,@selected_date.day)
  end

  private

    def authorize_person!
      redirect_to root_path unless current_person.projects.size > 0
    end

    def get_selected_date
      if params[:year] and params[:month] and params[:day]
        @selected_date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
      else
        @selected_date = Date.today
      end
    end

end
