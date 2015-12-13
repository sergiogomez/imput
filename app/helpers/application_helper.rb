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

  def lang_switcher
    I18n.available_locales.each do |loc|
      locale_param = request.path == root_path ? root_path(locale: loc) : params.merge(locale: loc)
      concat content_tag(:li, (link_to loc.upcase, locale_param), class: (I18n.locale == loc ? "active" : ""))
    end;
  end
end
