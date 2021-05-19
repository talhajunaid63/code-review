require "test_helper"
feature "PatientsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @coordinator = coordinators(:coordinator_46)
    @organization = organizations(:uvo_health)
    @patient = patients(:patient_45)
    stubs_text_message_send_text
  end

  scenario "Create - validations works correctly" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit new_organization_patient_path(@organization)
    expect(page).must_have_content("Set Up a Patient/Client")
    within("form#new_patient") do
      click_button "Create Patient/Client"
    end
    expect(page).must_have_content("Sorry.")
    expect(page).must_have_content("1 issue must be addressed to continue.")
    expect(page).must_have_content("Email & Phone both are blank. Atleast one is needed")
  end

  scenario "Update - validations works correctly" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit edit_organization_patient_path(@organization, @patient)
    expect(page).must_have_content("Edit Patient/Client")
    within("form#edit_patient_#{@patient.id}") do
      fill_in("patient_phone", with: "")
      click_button "Update Patient"
    end
    expect(page).must_have_content("Sorry.")
    expect(page).must_have_content("1 issue must be addressed to continue.")
    expect(page).must_have_content("Email & Phone both are blank. Atleast one is needed")
  end

  scenario "Patient does not see Archive button or Coordinator selector" do
    authenticate_user(@patient, @patient.phone)
    visit edit_organization_patient_path(@organization, @patient)
    expect(page).must_have_content("My Info")
    expect(page).wont_have_content("Assigned Coordinator")
    expect(page).wont_have_content("Archive Patient")
  end

end
