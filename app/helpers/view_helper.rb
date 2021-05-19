module ViewHelper

  def int_as_day(int)
    case int
      when  0
        "Sunday"
      when 1
        "Monday"
      when 2
        "Tuesday"
      when 3
        "Wednesday"
      when 4
        "Thursday"
      when 5
        "Friday"
      when 6
        "Saturday"
      else
    end
  end

  def int_as_time(int)
    case int
    when 0
      "Midnight - 2am"
    when 1
      "2am - 4am"
    when 2
      "4am - 6am"
    when 3
      "6am - 8am"
    when 4
      "8am - 10am"
    when 5
      "10am - Noon"
    when 6
      "Noon - 2pm"
    when 7
      "2pm - 4pm"
    when 8
      "4pm - 6pm"
    when 9
      "6pm - 8pm"
    when 10
      "8pm - 10pm"
    when 11
      "10pm - Midnight"
    end
  end

  def block_start(int)
    case int
    when 0
      6
    when 1
      8
    when 2
      10
    when 3
     12
    when 4
      2
    when 5
     4
    when 6
      6
    when 7
     8
    when 8
     10
    end
  end

  def am_pm(int)
    if int > 2
      'pm'
    else
      'am'
    end
  end


  def mobile_date(date)
    date.strftime('%A')
  end

  def block_formatted_date(date)
    date.strftime("%A, %B #{date.day.ordinalize}")
  end

  def show_time_slot?(time)
    time > (DateTime.now + 1.hour)
  end

  def navigation_bar(text, options = {})
    hide_back = options[:hide_back]
    url = options[:url]
    return nav_bar_with_url(text, url) if url
    return nav_bar_no_back(text) if hide_back
    javascript_back(text)
  end

  def nav_bar_no_back(text)
    %(<div class='container-fluid bgray hidden-xs'>
        <div class='col-md-6 col-md-offset-3 text-center'>
          <h3 class='white'>#{text}</h3>
        </div>
      </div>
      <div class='container-fluid bgray gpad visible-xs'>
       <a href='#' onclick='history.back()' class='white'>
        <div class='col-xs-3'>
        </div>
        <div class='col-xs-6 text-center'>
          <span class='lead white'>#{text}</span>
        </div>
      </a>
      </div>).html_safe
  end

  def nav_bar_with_url(text, url)
    %(<a href='#{url}' class='white'>
      <div class='container-fluid bgray hidden-xs'>
        <div class='col-md-3'>
          <h3><i class='fa fa-arrow-left' aria-hidden='true'></i> Back</h3></a>
        </div>
        <div class='col-md-6 text-center'>
          <h3 class='white'>#{text}</h3>
        </div>
      </div>
    </a>

    <div class='container-fluid bgray gpad visible-xs'>
     <a href='#' onclick='history.back()' class='white'>
      <div class='col-xs-3'>
        <i class='fa fa-arrow-left' aria-hidden='true'></i>
      </div>
      <div class='col-xs-6 text-center'>
        <span class='lead white'>#{text}</span>
      </div>
    </a>
    </div>).html_safe
  end

  def javascript_back(text)
    %(<a href='#' onclick='history.back()' class='white'>
      <div class='container-fluid bgray hidden-xs'>
        <div class='col-md-3'>
          <h3><i class='fa fa-arrow-left' aria-hidden='true'></i> Back</h3></a>
        </div>
        <div class='col-md-6 text-center'>
          <h3 class='white'>#{text}</h3>
        </div>
      </div>
    </a>

    <div class='container-fluid bgray gpad visible-xs'>
     <a href='#' onclick='history.back()' class='white'>
      <div class='col-xs-3'>
        <i class='fa fa-arrow-left' aria-hidden='true'></i>
      </div>
      <div class='col-xs-6 text-center'>
        <span class='lead white'>#{text}</span>
      </div>
    </a>
    </div>).html_safe
  end
end
