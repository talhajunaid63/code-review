require "test_helper"
feature "OrgSetupsProvidersControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    StripeMock.start
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 6)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "new" do
    skip
    within "#new_org_setup_marketing_setting" do
      fill_in "org_setup_marketing_setting_brand_color", with: "#9999FF"
      click_button "Update Organization"
    end
    @organization.reload
    assert_equal "#9999FF", @organization.brand_color
  end

  scenario "step can be skipped" do
    click_link "Skip for now"
    expect(page).must_have_content "Visit Length"
  end

  scenario "Error Validation" do
    skip
    within "#new_org_setup_marketing_setting" do
      fill_in "org_setup_marketing_setting_brand_color", with: "#9999FF"
      # attach_file "org_setup_marketing_setting[logo]",
      click_button "Update Organization"
    end
    @organization.reload
    assert_equal nil, @organization.logo
    expect(page).must_have_content "content type is invalid"
  end
end
