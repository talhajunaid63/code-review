module ApplicationHelper
  def checked_notify?
    cookies[:checked_notify].present?
  end

  def ring_mp3_url
    "https://uvohealth-marketing-aws.s3-us-west-1.amazonaws.com/ring.mp3"
  end

  def expiring_url_time_in_seconds
    1.week.to_i
  end

  def markdown(data)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, safe_links_only: true, escape_html: true, prettify: true)
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(data).html_safe
  end

  def show_title_for(organization)
    if organization
      organization.name
    else
      "Uvo Health"
    end
  end

  def org_admin_privilege?(user)
    user.org_admin? ||
      user.administrator? ||
      (user.provider? && user.provider_detail&.acts_as_org_admin) ||
      (user.coordinator? && user.coordinator_detail&.acts_as_org_admin)
  end

  def coordinator_or_org_admin_access?(user)
    user.administrator? ||
      user.org_admin? ||
      user.coordinator? ||
      user.provider? && org_admin_privilege?(current_user)
  end

  def coordinator_or_org_admin_or_provider_access?(user)
    user.administrator? || user.org_admin? || user.coordinator? || user.provider?
  end

  def current_class?(test_path)
    return 'active' if request.path == test_path
    ''
  end

  def sidebar_active_class(test_path)
    return 'active' if request.path == test_path
    ''
  end

  def doc_name(file_name)
    file_name.split('app/views/api_docs/v1/').last.gsub('.md','')
  end

  def get_time_zone_key_from_value(time_zone_value)
    ActiveSupport::TimeZone::MAPPING.key(time_zone_value)
  end

  def show_summary_type(type, count)
    klass = {
      created: "bgreen",
      updated: "bgray",
      failed: "bred",
    }[type]
    content_tag :h2, "#{type.to_s.humanize} (#{count})", class: [klass, "gpad"].join(" ")
  end

  def orgnaziation_specific_classes(organization)
    return 'container-fluid fullheight' if organization

    'bbluegrad fullheight new-session-page'
  end

  def organization_styles(organization)
    "background: linear-gradient(-90deg, rgba(0,0,0,.1), rgba(0,0,0,.2));background-color:#{organization.brand_color};"
  end

  def user_summary_status(status)
    status.titleize
  end

  def user_summary_records(total)
    total.zero? ? '-' : total
  end

  def user_summary_percentage(summary)
    return 0 if summary.total.zero?
    return 100 if summary.completed?

    ((summary.processed.to_f / summary.total.to_f) * 100).round(2)
  end

  def true?(value)
    value == 'true'
  end
end
