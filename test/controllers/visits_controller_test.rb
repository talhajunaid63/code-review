require "test_helper"
feature "VisitsControllerTest" do
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @coordinator = coordinators(:coordinator_14)
    @other_coordinator = coordinators(:coordinator_19)
    @organization = organizations(:rmg)
    @patient = patients(:patient_20)
    @provider = providers(:provider_antoine)
    stubs_text_message_send_text
    apply_db_triggers @patient
  end

  scenario "patients cannot see others visits" do
    authenticate_user(@patient, @patient.phone)
    visit "/organizations/#{@patient.organization.slug}/patients/#{@patient.id}/visits"
    expect(page).must_have_content("Sorry, You are not authorized to access this page")
  end

  scenario "Coordinator Index Filter Hides Visits for Others" do
    authenticate_user(@coordinator, @coordinator.phone)
    visit organization_visits_path(@organization, filter: "assigned")
    assert page.has_content? "Visits"
    refute page.has_content? @other_coordinator.name
  end

  scenario "RIGHT NOW visit - notifies patient when a provider enters the visit room" do
    $sms_log = []
    ActionMailer::Base.deliveries = []
    stubs_open_tok_create_session
    stubs_open_tok_generate_token
    right_now_visit = Visit.create(
      patient_id: @patient.id,
      organization_id: @organization.id,
      schedule: Time.now,
      status: 11
    )
    authenticate_user(@provider, @provider.phone)
    visit organization_visit_path(@organization, right_now_visit)
  end

end
