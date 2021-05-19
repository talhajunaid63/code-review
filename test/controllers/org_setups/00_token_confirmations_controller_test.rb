require "test_helper"
feature "OrgSetupsTokenConfirmationControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    @phone = "5550995555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 2)
  end

  scenario "new" do
    @org_setups_before = OrgSetup.all.count
    expect(page).must_have_content "We sent a code to"
    expect(page).must_have_content @phone.delete("^0-9")
    fill_in "org_setup_token_confirmation[token]", with: "12345"
    click_button "Confirm"
    assert_equal @org_setups_before + 1, OrgSetup.all.count
  end

  scenario "Incorrect token shows error flash" do
    @org_setups_before = OrgSetup.all.count
    fill_in "org_setup_token_confirmation[token]", with: "57462"
    click_button "Confirm"
    expect(page).must_have_content "Looks like you may have entered your phone number, email or code incorrectly"
    assert_equal @org_setups_before, OrgSetup.all.count
  end

  scenario "Invalid token shows error flash" do
    @org_setups_before = OrgSetup.all.count
    fill_in "org_setup_token_confirmation[token]", with: "123456"
    click_button "Confirm"
    expect(page).must_have_content "Must be 5 digits"
    assert_equal @org_setups_before, OrgSetup.all.count
  end
end
