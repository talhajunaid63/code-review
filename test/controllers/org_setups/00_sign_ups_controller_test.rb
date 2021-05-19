require "test_helper"
feature "OrgSetupsSignUpsControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    @phone = "555-099-5555"
    org_onboarding_setup(@phone, 1)
    stubs_text_message_send_text
  end

  scenario "new" do
    @org_admins_before = OrgAdmin.all.count
    expect(page).must_have_content "Let's create your account!"
    fill_in "org_setup_sign_up[login_handler]", with: "555-099-5555"
    click_button "Request Sign In Code"
    assert_equal @org_admins_before + 1, OrgAdmin.all.count
  end

  scenario "Taken login can also be used to signup" do
    @org_admins_before = OrgAdmin.all.count
    expect(page).must_have_content "Let's create your account!"
    fill_in "org_setup_sign_up[login_handler]", with: "555-555-5555"
    click_button "Request Sign In Code"
    assert_equal @org_admins_before + 1 , OrgAdmin.all.count
  end
end
