class VisitRecordingDecorator < SimpleDelegator
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  extend ActiveModel::Naming

  def self.wrap(collection)
    collection.map do |obj|
        new obj
    end
  end

  def render_time_with_duration(time)
    return "N/A" unless time.present?

    title = Time.at(time).strftime('%m/%d/%Y %H:%M %p')

    content_tag(:span, title: title) do
      content_tag :time, "", class: "timeago", datetime: time
    end
  end

  def recording_date
    render_time_with_duration(recorded_at)
  end

  def download_date
    render_time_with_duration(downloaded_at)
  end

  def expiry_date
    render_time_with_duration(expired_at)
  end

  def coordinator_name
    visit.coordinator_name.presence || "N/A"
  end
end
