require "test_helper"
feature "ProgramAutomatorReminders" do

  # NOTE - If rake tasks are not scheduled on the server they will not send.
  # They must be specifically invoked as in the tests below, a scheduler is how this is implemented.
  include TextMessageHelper

  setup do
    Sidekiq::Testing.inline!
    @visit = visits(:visit_1)
    Delorean.back_to_the_present
    Rake::Task.clear
    $sms_log = ['No SMS Sent']
    stubs_text_message_send_text
  end

  scenario "Patient gets an sms reminder 1 day before the visit schedule date" do
    Delorean.time_travel_to (@visit.schedule - 1.days) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    Delorean.back_to_the_present
  end

  scenario "Provider gets an email reminder 30 minutes before the visit schedule date" do
    add_provider_to_visit
    Delorean.time_travel_to (@visit.schedule - 30.minutes) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    Delorean.back_to_the_present
  end

  scenario "Visits without a provider_id no reminder will be sent" do
    ActionMailer::Base.deliveries = []
    Delorean.time_travel_to (@visit.schedule - 30.minutes) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert $sms_log == ['No SMS Sent']
    Delorean.back_to_the_present
  end

  scenario "Patients does not get sms reminders if reminder patient content is blank" do
    sms_reminder_setting = @visit.organization.sms_reminder_setting
    sms_reminder_setting.patient_content = ""
    sms_reminder_setting.save
    Delorean.time_travel_to (@visit.schedule - 1.days) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert $sms_log == ['No SMS Sent']
    Delorean.back_to_the_present
  end

  scenario "Providers does not get sms reminders if reminder provider content is blank" do
    add_provider_to_visit
    sms_reminder_setting = @visit.organization.sms_reminder_setting
    sms_reminder_setting.provider_content = ""
    sms_reminder_setting.save
    Delorean.time_travel_to (@visit.schedule - 30.minutes) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert $sms_log == ['No SMS Sent']
    Delorean.back_to_the_present
  end

  def add_provider_to_visit
    provider = providers(:provider_helena)
    @visit.providers << provider
    @visit.save
  end
end
