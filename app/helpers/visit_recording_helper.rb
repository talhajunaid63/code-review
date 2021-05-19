module VisitRecordingHelper
  def recording_sort_select_options
    [
      ['Recording time', 'recorded_at'],
      ['Expiration time', 'expired_at']
    ]
  end

  def formatted_duration(duration)
    return "N/A" unless duration.present?

    distance_of_time_in_words(duration)
  end
end
