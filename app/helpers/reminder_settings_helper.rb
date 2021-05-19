module ReminderSettingsHelper

  def reminders_send_at_array
    [
      ["Do not Send", "0"],
      ["1 Day Before", "1.day"],
      ["3 Hours Before", "3.hours"],
      ["2 Hours Before", "2.hours"],
      ["1 Hours Before", "1.hour"],
      ["1 Day Before", "1.day"],
      ["30 Minutes Before", "30.minutes"],
      ["15 Minutes Before", "15.minutes"],
    ]
  end

  def render_sms_reminder_content_warning_for_patient(sms_reminder_setting)
    return "" unless sms_reminder_setting.patient_content.blank?  && sms_reminder_setting.patient_send_at != "0"
    html = "<p><strong class='label label-danger'>Patient/Client Reminder Content is currently blank</strong> <br>"
    html << "<small class='text-danger'>No SMS reminder will be sent to patients/clients.</small></p>"
    html.html_safe
  end

  def render_email_reminder_content_warning_for_patient(email_reminder_setting)
    return "" if email_reminder_setting.patient_send_at == "0"
    return "" unless email_reminder_setting.patient_subject.blank? || email_reminder_setting.patient_content.blank?
    html = "<p><strong class='label label-danger'>Patient/Client Reminder Content or Subject is currently blank</strong> <br>"
    html << "<small class='text-danger'>No Email reminder will be sent to patients/clients.</small></p>"
    html.html_safe
  end

  def render_sms_reminder_content_warning_for_provider(sms_reminder_setting)
    return "" unless sms_reminder_setting.provider_content.blank?  && sms_reminder_setting.provider_send_at != "0"
    html = "<p><strong class='label label-danger'>Provider Reminder Content is currently blank</strong> <br>"
    html << "<small class='text-danger'>No SMS reminder will be sent to providers.</small></p>"
    html.html_safe
  end

  def render_email_reminder_content_warning_for_provider(email_reminder_setting)
    return "" if email_reminder_setting.provider_send_at == "0"
    return "" unless email_reminder_setting.provider_subject.blank? || email_reminder_setting.provider_content.blank?
    html = "<p><strong class='label label-danger'>Provider Reminder Content or Subject is currently blank</strong> <br>"
    html << "<small class='text-danger'>No Email reminder will be sent to providers.</small></p>"
    html.html_safe
  end
end
