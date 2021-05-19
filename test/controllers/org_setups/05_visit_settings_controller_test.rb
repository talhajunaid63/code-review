require "test_helper"
feature "OrgSetupsVisitSettingsControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    StripeMock.start
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 7)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "user can accept defaults by clicking Save Settings" do
    click_button "Save Settings"
    expect(page).must_have_content "Patient/Client Data Settings"
  end

  scenario "Error Validation" do
    skip
  end
end
