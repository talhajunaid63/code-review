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
    stubs_text_message_send_text
  end

  scenario "Visits without a provider_id no reminder will be sent" do
    ActionMailer::Base.deliveries = []
    Delorean.time_travel_to (@visit.schedule - 30.minutes) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert_equal 0, ActionMailer::Base.deliveries.count
    Delorean.back_to_the_present
  end

  scenario "Patient does not get email reminders if patient content or subject is blank" do
    email_reminder_setting = @visit.organization.email_reminder_setting
    email_reminder_setting.patient_subject = ""
    email_reminder_setting.save
    ActionMailer::Base.deliveries = []
    Delorean.time_travel_to (@visit.schedule - 1.days) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert_equal 0, ActionMailer::Base.deliveries.count
    Delorean.back_to_the_present
  end

  scenario "Provider does not get email reminders if provider content or subject is blank" do
    add_provider_to_visit
    email_reminder_setting = @visit.organization.email_reminder_setting
    email_reminder_setting.provider_subject = ""
    email_reminder_setting.save
    ActionMailer::Base.deliveries = []
    Delorean.time_travel_to (@visit.schedule - 30.minutes) + 1.minutes
    Urgentcare::Application.load_tasks
    Rake::Task["scheduler:visit_reminders"].invoke
    assert_equal 0, ActionMailer::Base.deliveries.count
    Delorean.back_to_the_present
  end

  def add_provider_to_visit
    provider = providers(:provider_helena)
    @visit.providers << provider
    @visit.save
  end
end
