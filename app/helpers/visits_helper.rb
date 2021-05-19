module VisitsHelper

  def provider_options_right_now
    current_user.provider? && user_options_right_now || []
  end

  def coordinator_options_right_now
    current_user.coordinator? && user_options_right_now || []
  end

  def user_options_right_now
    options_for_select([[current_user.name, current_user.id]], selected: current_user.id)
  end

  def visit_enter_room_text(user, visit)
    return "Enter Visit Room" unless user.patient?
    return "Start Video Chat" if visit.now?
    "Enter Waiting Room"
  end

  def visit_provider(visit)
    visit.providers_names.join(" & ")
  end

  def one_provide(provider_id)
    Provider.find(provider_id).name
  end

  def more_than_one_provider(provider_ids)
    provider = []
    provider_ids.each do |id|
      provider << Provider.find(id).name
    end
    provider.join(" & ")
  end

  def provider_names(providers)
    providers&.map(&:name)&.join(' & ')
  end

  def os_information(video_log)
    info = "#{video_log.os} #{video_log.os_version}"
    info = "#{info} (mobile)" if video_log.mobile.eql?('true')

    info
  end

  def old_ios?
    browser.device.mobile? && browser.platform.ios? && browser.version.to_f < 11
  end

  def category_label_class(pre_test)
    {
      'success' => 'label-success',
      'failed' => 'label-danger',
      'pending' => 'label-warning'
    }[pre_test.category_status]
  end

  def diagnosis_search_key_words_example
    Diagnosis.first(3).pluck(:diag_description).map { |disc| disc.split(' ').first }.join(', ')
  end

  def pre_test_suggestion(pre_test_detail)
    patient_browser = Browser.new(pre_test_detail.user_agent)

    if patient_browser.device.mobile? && patient_browser.platform.ios?
      return 'Do not use iOS devices with iOS version 13 and above.' if patient_browser.version.to_f <= 12
      return 'Do not use iOS devices with iOS version 12 and below.'
    end


    if pre_test_detail.codecs.size == 2
      'You can use any device'
    elsif pre_test_detail.codecs.include?('VP8')
      'Do not use iOS devices with iOS version 12 and below.'
    elsif pre_test_detail.codecs.include?('H264')
      'Do not use iOS devices with iOS version 13 and above. Also do not use android devices with android version 5 and below.'
    else
      'There is no support for the device'
    end
  end
end
