module ApplicationHelper

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  def nice_time(num)
    if use_nice_time?
      decimal_time_to_hours(num)
    else
      sprintf("%.02f", num.round(2))
    end
  end

  def decimal_time_to_hours(num)
    sign = num < 0 ? '-' : ''
    hours = num.abs.to_i.to_s
    if num >= 0
      minutes = ((num % 1) * 60).round.to_s
    else
      minutes = (60 - (num % 1) * 60).round.to_s
      minutes = '00' if minutes == '60'
    end
    sign + hours.rjust(2,'0') + ":" + minutes.rjust(2,'0')
  end

  def use_nice_time?
    !current_person.time_decimal
  end
  
end
