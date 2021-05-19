require "test_helper"
feature "SmsReminderSettingsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_jeanette)
    @organization = organizations(:uvo_health)
    stubs_text_message_send_text
  end

  scenario "Index creates and displays SMS reminder settings" do
    authenticate_user(@org_admin, @org_admin.phone)
    assert @organization.sms_reminder_setting.nil?
    visit organization_sms_reminder_settings_path(@organization)
    expect(page).must_have_content("Edit SMS Reminder Settings")
    @organization.reload
    assert !@organization.sms_reminder_setting.nil?
  end

  scenario "Update" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_sms_reminder_settings_path(@organization)
    expect(page).must_have_content("Edit SMS Reminder Settings")
    sms_reminder_setting = @organization.sms_reminder_setting
    within("form#edit_organization_sms_reminder_setting_#{sms_reminder_setting.id}") do
      select("3 Hours Before", from: "organization_sms_reminder_setting_patient_send_at")
      fill_in("organization_sms_reminder_setting_patient_content", with: "Patient Content")
      click_button "Save Settings"
    end
    sms_reminder_setting.reload
    assert_equal "3.hours", sms_reminder_setting.patient_send_at
    assert_equal "Patient Content", sms_reminder_setting.patient_content
    assert_equal "0", sms_reminder_setting.provider_send_at
  end
end
