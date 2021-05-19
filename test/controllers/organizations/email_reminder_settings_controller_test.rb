require "test_helper"
feature "EmailReminderSettingsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_jeanette)
    @organization = organizations(:uvo_health)
    stubs_text_message_send_text
  end

  scenario "Index creates and displays email reminder settings" do
    authenticate_user(@org_admin, @org_admin.phone)
    assert @organization.email_reminder_setting.nil?
    visit organization_email_reminder_settings_path(@organization)
    expect(page).must_have_content("Edit Email Reminder Setting")
    @organization.reload
    assert !@organization.email_reminder_setting.nil?
  end

  scenario "Update" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_email_reminder_settings_path(@organization)
    expect(page).must_have_content("Edit Email Reminder Setting")
    email_reminder_setting = @organization.email_reminder_setting
    within("form#edit_organization_email_reminder_setting_#{email_reminder_setting.id}") do
      select("3 Hours Before", from: "organization_email_reminder_setting_patient_send_at")
      fill_in("organization_email_reminder_setting_patient_subject", with: "Patient Subject")
      fill_in("organization_email_reminder_setting_patient_content", with: "Patient Content")
      click_button "Save Settings"
    end
    email_reminder_setting.reload
    assert_equal "3.hours", email_reminder_setting.patient_send_at
    assert_equal "Patient Subject", email_reminder_setting.patient_subject
    assert_equal "Patient Content", email_reminder_setting.patient_content
    assert_equal "0", email_reminder_setting.provider_send_at
  end
end
