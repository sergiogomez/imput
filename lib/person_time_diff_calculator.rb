class PersonTimeDiffCalculator

  attr_reader :person, :date_today, 
              :hours_today, :hours_yesterday, :diff_hours_today,
              :hours_this_week, :hours_last_week, :diff_hours_this_week,
              :hours_this_month, :hours_last_month, :diff_hours_this_month,
              :hours_this_quarter, :hours_last_quarter, :diff_hours_this_quarter,
              :current_time_entry

  def initialize person, date_today
    @person = person
    @date_today = date_today
  end

  def process
    yesterday_difference
    week_difference
    month_difference
    quarter_difference
    calculate_current_time_entry
  end

  private

  def yesterday_difference
    @hours_today = TimeEntry.day_time(person, date_today)
    @hours_yesterday = TimeEntry.day_time(person, date_today - 1)
    @diff_hours_today = (hours_today - hours_yesterday).round(2)
  end

  def week_difference
    @hours_this_week = TimeEntry.week_total_time(person, date_today.beginning_of_week)
    @hours_last_week = TimeEntry.week_total_time(person, (date_today - 7).beginning_of_week)
    @diff_hours_this_week = (hours_this_week - hours_last_week).round(2)
  end

  def month_difference
    @hours_this_month = TimeEntry.month_total_time(person, date_today)
    @hours_last_month = TimeEntry.month_total_time(person, date_today - 1.month)
    @diff_hours_this_month = (hours_this_month - hours_last_month).round(2)
  end

  def quarter_difference
    @hours_this_quarter = TimeEntry.quarter_total_time(person, date_today)
    @hours_last_quarter = TimeEntry.quarter_total_time(person, date_today - 3.month)
    @diff_hours_this_quarter = (hours_this_quarter - hours_last_quarter).round(2)
  end

  def calculate_current_time_entry
    @current_time_entry = person.current_time_entry || person.dashboard_last_time_entry
  end

end