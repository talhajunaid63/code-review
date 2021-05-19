require "test_helper"
feature "SignUpBasicsTest" do
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:uvo_health)
    @patient = patients(:patient_44)
    stubs_open_tok_create_session
    stubs_text_message_send_text
  end

  scenario "Valid sign up basics form submits and saves" do
    authenticate_user(@patient, @patient.phone)
    visit organization_patient_build_path(:basics, organization_id: @organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("What is your name and gender?")
    within("form#edit_patient_#{@patient.id}") do
      fill_in("patient_first_name", with: "Samantha")
      fill_in("patient_last_name", with: "Hill")
      select("Female", from: "patient_basic_detail_attributes_gender")
    end
    click_button "Save & Continue"
    expect(page).must_have_content("Setup a Visit")
    @patient.reload
    assert_equal 1, @patient.gender
    expect(page).must_have_content("What brings you in today?")
  end

end
