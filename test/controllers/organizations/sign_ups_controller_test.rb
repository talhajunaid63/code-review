require "test_helper"
feature "OrganizationSignUpsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:uvo_health)
    @phone = patients(:patient_1).phone
    stubs_text_message_send_text
  end

  scenario "Patient can sign up successfully", js: true do
    @patient_count_before = Patient.count
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content "mobile phone number"
    fill_in "input_trigger", with: @phone
    check "terms-checkbox", visible: false
    click_button "Request Sign In Code"
    expect(page).must_have_content "We sent a code to"
    assert_equal @patient_count_before + 1, Patient.count
  end

  scenario "Patient cannot sign up without checking box to agree to terms (frontend validation only)", js: true do
    @patient_count_before = Patient.count
    visit new_organization_sign_up_path(@organization)
    expect(page).must_have_content "mobile phone number"
    fill_in "input_trigger", with: @phone
    click_button "Request Sign In Code"
    expect(page).wont_have_content "We sent a code to"
    expect(page).must_have_content "mobile phone number"
    assert_equal @patient_count_before, Patient.count
  end
end
