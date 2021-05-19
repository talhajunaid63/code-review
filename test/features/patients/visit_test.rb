require "test_helper"
feature "PatientVisitTest" do
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    stubs_open_tok_create_session
    stubs_open_tok_generate_token
    stubs_text_message_send_text
    @patient = patients(:patient_20)
    @organization = organizations(:rmg)
    @visit = visits(:visit_4)
    @visit.update_open_tok_data
  end

  scenario "Patient can enter and exit a visit" do
    @patient.user_visit_consents.each &:destroy
    authenticate_user(@patient, @patient.phone)
    visit dashboard_organization_patient_path(@organization, @patient)
    page.assert_selector(:css, "a[href='/organizations/#{@organization.slug}/visits/#{@visit.id}']")
    visit organization_visit_path(@organization, @visit)

    if !@visit.right_now?
      find(:id, 'legal_release_confirmation').set(true)
      page.find('input[type=submit]').click
    end

    click_link "End Visit"
    expect(page).must_have_content(/Your visit * is now concluded./)

    click_link 'Visit History'
    expect(page).must_have_content('Upcoming Visits')
  end

  scenario "Patient is asked to confirm consent when recording is enabled" do
    @organization.enable_recording = true
    @organization.save
    @patient.user_visit_consents.each &:destroy

    authenticate_user(@patient, @patient.phone)
    visit dashboard_organization_patient_path(@organization, @patient)
    expect(page).must_have_content("Enter Waiting Room")
  end

  scenario "Coordinator can Confirm consent and open visit" do
    @organization.enable_recording = true
    @organization.save
    @patient.user_visit_consents.each &:destroy

    authenticate_user(@patient, @patient.phone)
    visit dashboard_organization_patient_path(@organization, @patient)
    first(:link, "Enter Waiting Room").click
    expect(page).must_have_content("Confirm Consent")
    within("form#new_legal_release") do
      check "legal_release_confirmation"
    end
    click_button "Save & Continue"
    expect(page).must_have_content("End Visit")
  end

  scenario 'Visit Invitation', js: true do
    @visit = visits(:visit_19)
    @visit.update_open_tok_data
    @provider = providers(:provider_blanch)
    @coordinator = coordinators(:southwest_medical_org_coordinator)
    apply_db_triggers @coordinator

    authenticate_user(@provider, @provider.phone)
    visit organization_visit_path(@visit.organization, @visit)

    assert_equal 3, @visit.participants.count

    page.execute_script %Q{ $('#visit-show-page').removeClass('d-none') }
    page.execute_script %Q{ $('#invite-btn').click() }
    expect(page).must_have_content('Invite Participants')

    select2 @coordinator.first_name, from: 'Coordinator(s)', search: true
    page.find('#send-invitation-btn').click
    expect(page).must_have_content('Invitation Successfully Sent.')

    @visit.reload
    assert_equal 4, @visit.participants.count
    assert @visit.participants.include?(@coordinator), "#{@coordinator.name} not found in visit's participants"
  end

end
