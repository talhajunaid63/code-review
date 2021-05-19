require "test_helper"
feature "PatientSetUpAVisit" do
  include AuthenticationHelper
  include PaymentHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:rmg)
    @patient = patients(:patient_1)
    stubs_open_tok_create_session
    visit_settings = VisitSetting.find_or_create_by(organization_id: @organization.id)
    visit_settings.update(require_payment: true)
    stubs_text_message_send_text
  end

  scenario "A patient can set up a visit" do
    authenticate_user(@patient, @patient.phone)
    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("What brings you in today?")
    visit = Visit.last

    fill_patient_notes_form(visit)
    expect(page).must_have_content("Medical Details")
    expect(page).must_have_content("Medications")

    fill_medication_form(visit)
    fill_conditions_form(visit)

    click_button "Save & Continue"

    expect(page).must_have_content("Schedule")
    select_first_available_time

    expect(page).must_have_content("Update Payment Method")

    patient_add_payment(@patient)
    visit current_path

    expect(page).must_have_content("Medications")
    click_button "Confirm Session"
    expect(page).must_have_content("Upcoming Visits")
  end

  scenario "Patient can schedule a visit if medications are not required by Org" do
    metadata_settings = MetadataSetting.find_or_create_by(organization_id: @organization.id)
    metadata_settings.update(medications: false)

    authenticate_user(@patient, @patient.phone)
    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("What brings you in today?")
    visit = Visit.last

    fill_patient_notes_form(visit)
    expect(page).must_have_content("Medical Details")
    expect(page).wont_have_content("Medications")

    click_link "Skip this step"

    expect(page).must_have_content("Schedule")
    select_first_available_time

    expect(page).must_have_content("Update Payment Method")

    patient_add_payment(@patient)
    visit current_path

    expect(page).wont_have_content("Medications")
    click_button "Confirm Session"
    expect(page).must_have_content("Upcoming Visits")
  end

  scenario "Patient can add incident information if required by Org" do
    metadata_settings = MetadataSetting.find_or_create_by(organization_id: @organization.id)
    metadata_settings.update(incident_information: true)

    authenticate_user(@patient, @patient.phone)
    @patient&.basic_detail&.update(client_unique_id: '12345678')
    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)

    expect(page).must_have_content('Workplace Incident Information')
    visit = Visit.last
    patient_add_payment(@patient) if @patient.organization.payment_required? && !@patient.has_payment?

    fill_incident_information_form(visit)
    expect(page).must_have_content("Medical Details")
    expect(page).must_have_content("Medications")

    fill_medication_form(visit)
    fill_conditions_form(visit)

    click_button "Save & Continue"

    if !@patient.consented?(visit)
      expect(page).must_have_content('Confirm Consent')

      page.find('#legal_release_confirmation', visible: false).click
      page.find('input[type=submit]').click
    end

    expect(page).must_have_content('Next steps To enter the waiting room immediately')
  end

  scenario "Send notification to providers only once", js: true do
    authenticate_user(@patient, @patient.phone)
    @patient.user_visit_consents.each &:destroy
    @patient&.basic_detail&.update(client_unique_id: '12345678')
    patient_add_payment(@patient) if @patient.organization.payment_required? && !@patient.has_payment?
    visit dashboard_organization_patient_path(@organization, @patient)
    click_link 'Set Up Visit'
    expect(page).must_have_content('Medical Details')

    click_link 'Skip this step'
    expect(page).must_have_content('Confirm Consent')

    page.find('#legal_release_confirmation', visible: false).click
    page.find('input[type=submit]').click

    create_service = Visits::RightNow::CreateService.new(visit_id: Visit.last.id)
    create_service.stubs(:perform).returns(true)
    click_link 'Notify me via Text/SMS'
    assert create_service.perform
    expect(page).must_have_content('Thank you, we will send you a message when the doctor arrives')

    visit_update_at = Visit.last.updated_at
    page.driver.go_back

    click_link 'Notify me via Text/SMS'
    assert Visit.last.updated_at, visit_update_at
    expect(page).must_have_content('Thank you, we will send you a message when the doctor arrives')
  end

  def select_first_available_time
    within(".schedule_panel") do
      first("input[type='submit']").click
    end
  end

  def fill_patient_notes_form(visit)
    within("form#edit_visit_#{visit.id}") do
      fill_in("visit_patient_notes", with: "Test notes")
    end
    click_button "Save & Continue"
  end

  def fill_incident_information_form(visit)
    within("form#new_incident_information") do
      fill_in("incident_information_incident_description", with: "Test Incident Description")
      fill_in("incident_information_activity_performed", with: "Test Activity Performed")
    end
    click_button "Save & Continue"
  end

  def fill_medication_form(visit)
    within("form#edit_visit_#{visit.id}") do
      fill_in("visit_medications_attributes_0_name", with: "Test Medication")
      select("Less than a month", from: "visit_medications_attributes_0_how_long")
    end
  end

  def fill_conditions_form(visit)
    within("form#edit_visit_#{visit.id}") do
      fill_in("visit_conditions_attributes_0_name", with: "Test Condition")
    end
  end

end
