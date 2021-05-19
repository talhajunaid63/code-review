require "test_helper"
feature "CoordinatorRoleTest" do
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @coordinator = coordinators(:coordinator_14)
    @organization = organizations(:rmg)
    @patient = patients(:patient_20)
    @provider = providers(:provider_antoine)
    stubs_text_message_send_text
    stubs_open_tok_create_session
    apply_all_users_triggers
  end

  scenario "Coordinator can view a list of providers" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_providers_path(@organization)
    expect(page).must_have_content(@provider.name)
    expect(page).must_have_content("Add New Provider")
  end

  scenario "Coordinator can view the visits index" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_visits_path(@organization)
    expect(page).must_have_content("Visits")
  end

  scenario "Coordinator can open visit from list", js: true  do
    @count_before = @organization.visits.count
    authenticate_user(@coordinator, @coordinator.phone)
    create_new_visit
    stubs_open_tok_generate_token
    visit organization_visits_path(@organization)
    link_to_visit = first(:link, 'Enter Visit Room')
    expect(page).must_have_content('Confirm Consent')
  end

  scenario "Coordinator can create a patient with phone" do
    authenticate_user(@coordinator, @coordinator.phone)
    @count_before =  @organization.patients.count
    visit organization_patients_path(@organization)
    click_link "Add New Patient"
    within("form#new_patient") do
      fill_in("patient_first_name", with: "John")
      fill_in("patient_last_name", with: "Doe")
      fill_in("patient_phone", with: "555 333 1234")
      click_button "Create Patient/Client"
    end
    expect(page).must_have_content("Patient Created!")
    expect(page).must_have_content("John Doe")
    assert_equal (@count_before + 1), @organization.patients.count
  end

  scenario "Coordinator can create a patient with email" do
    authenticate_user(@coordinator, @coordinator.phone)
    @count_before =  @organization.patients.count
    visit organization_patients_path(@organization)
    click_link "Add New Patient"
    within("form#new_patient") do
      fill_in("patient_first_name", with: "John")
      fill_in("patient_last_name", with: "Doe")
      fill_in("patient_email", with: "new_patient@fake.me")
      click_button "Create Patient/Client"
    end
    expect(page).must_have_content("Patient Created!")
    expect(page).must_have_content("John Doe")
    assert_equal (@count_before + 1), @organization.patients.count
  end

  scenario "Coordinator can create unassigned patient" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_patients_path(@organization)
    click_link "Add New Patient"
    within("form#new_patient") do
      fill_in("patient_first_name", with: "John")
      fill_in("patient_last_name", with: "Doe")
      fill_in("patient_email", with: "new_patient@fake.me")
      select("Unassigned", from: "patient_coordinator_id")
      click_button "Create Patient/Client"
    end
    expect(page).must_have_content("Patient Created!")
    expect(page).must_have_content("John Doe")
    assert_nil @organization.patients.last.coordinator_name
  end

  scenario "Coordinator can edit a Patient" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_patients_path(@organization, per_page: 100)
    click_link("edit_patient_link_#{@patient.id}")
    within("form#edit_patient_#{@patient.id}") do
      fill_in("patient_last_name", with: "Updated")
      click_button "Update Patient"
    end
    expect(page).must_have_content("Patient Updated")
    @patient.reload
    assert_equal "Updated", @patient.last_name
  end

  scenario "Coordinator can create a Patient visit from patients screen", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_patients_path(@organization, per_page: 100)
    click_link("new_patient_visit_link_#{@patient.id}")
    expect(page).must_have_content("New Visit")
    expect(page).must_have_content(@patient.name)
  end

  scenario "Coordinator can create a visit for an existing Patient", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    @count_before = @organization.visits.count
    create_new_visit
    expect(page).must_have_content("Enter Visit Room")
    assert_equal (@count_before + 1), @organization.visits.count
  end

  scenario "Coordinator can cancel a visit" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_visits_path(@organization)
    expect(page).must_have_content("Visits")
    visit = visits(:visit_1)
    assert_equal "Status Unknown", visit.status_text
    click_button "cancel-visit-button-#{visit.id}"
    within("form#edit_visit_1") do
      fill_in("visit_provider_notes", with: "Test Visit Cancellation")
      click_button "Cancel Visit"
    end
    expect(page).must_have_content("Visit cancelled & patient has been notified")
    visit.reload
    assert_equal "Visit Canceled", visit.status_text
  end

  scenario "Coordinator can create a right-now visit from visits screen", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_visits_path(@organization)
    expect(page).must_have_content("Visits")

    click_link 'Start a Right Now Visit'
    expect(page).must_have_content('Who do you want in this visit?')

    within("form#start_now_form") do
      select2 @provider.first_name, from: 'Provider(s)', search: true
      select2 @patient.first_name, from: 'Patient/Client', search: true
      click_button "Start Visit Now"
    end

    expect(page).must_have_content("Notifications (Email/SMS) Sent")
  end

  def create_new_visit
    schedule = @organization.schedule_select
    schedule_start = schedule.first.last
    schedule_end = schedule.second.last

    stubs_open_tok_create_session

    @visit = Visit.create(
      patient_id: @patient.id,
      organization_id: @organization.id,
      schedule: schedule_start,
      schedule_end: schedule_end,
    )
    assert_equal (@count_before + 1), @organization.visits.count
    visit organization_visits_path(@organization)
  end
end
