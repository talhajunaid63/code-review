require 'test_helper'

class WorkplaceIncidentRoundRobinDelayTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper
  include PaymentHelper

  setup do
    @uvo_health = organizations(:uvo_health)
    @uvo_health.metadata_settings.update(incident_information: true)

    @state = State.last
    @uvo_health.providers.each do |provider|
      provider.states << @state
      provider.available_times.create(day: Time.zone.now.wday, time_block: 5)
    end

    @params = {
      phone: '5555085555',
      client_unique_id: '12345678',
    }

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    Delorean.back_to_the_present
    stubs_open_tok_create_session
    stubs_text_message_send_text
  end

  test 'Workplace Incident Process test' do
    Delorean.time_travel_to(Time.zone.now.change(hour: 10))

    patient_starts_wi(@uvo_health, @params)
    @patient = Patient.last
    @patient.basic_detail.update(
      state: @state.code
    )
    assert @patient.basic_detail.client_unique_id == @params[:client_unique_id]

    visit organization_patient_build_url(:zip, organization_id: @uvo_health.slug, patient_id: @patient.id)

    patient_signs_in
    patient_enters_personal_information

    @visit = Visit.last

    patient_enters_visit_details
    click_on 'Notify me via Text/SMS'

    providers = @visit.organization.providers.order(:notifications_count).select do |provider|
      provider.same_state?(@patient) && provider.available?
    end.first(5)

    delay = [providers.present? ? (10 / providers.length) : 0, 3].min
    providers.shift
    count = 2

    while providers.present? do
      curr_set = Sidekiq::Worker.jobs
      providers.shift

      assert_equal curr_set.count, count
      count += 1
      assert_equal curr_set.first['wrapped'], 'ProviderNotificationsJob'

      args = curr_set.first['args'][0]['arguments']
      curr_set[-2]['wrapped'].constantize.new.perform(args[0], args[1], args[2])

      Delorean.time_travel_to(Time.now + delay.minutes)
    end

    Delorean.back_to_the_present
  end

  def patient_enters_visit_details
    expect(page).must_have_content('Workplace Incident Information')
    patient_add_payment(@patient) if @patient.organization.payment_required? && !@patient.has_payment?

    fill_incident_information_form(@visit)
    expect(page).must_have_content("Medical Details")
    expect(page).must_have_content("Medications")

    fill_medication_form(@visit)
    fill_conditions_form(@visit)
    click_button 'Save & Continue'

    if !@patient.consented?(@visit)
      expect(page).must_have_content('Confirm Consent')

      page.find('#legal_release_confirmation').click
      page.find('input[type=submit]').click
    end

    expect(page).must_have_content('Next steps To enter the waiting room immediately')
    @visit.reload
  end

  def patient_enters_personal_information
    expect(page).must_have_content "What's Your Zip Code?"
    within("form#edit_patient_#{@patient.id}") do
      fill_in('patient_zip', with: '93456')
    end
    click_button 'Save & Continue'

    @patient.reload
    assert_equal "93456", @patient.zip

    expect(page).must_have_content('Date of Birth')
    within("form#edit_patient_#{@patient.id}") do
      fill_in 'patient_date_of_birth', with: '02/06/1985'
    end
    click_button 'Save & Continue'

    @patient.reload
    assert_equal '02/06/1985', @patient.date_of_birth

    expect(page).must_have_content('Time Zone')
    within("form#edit_patient_#{@patient.id}") do
      select('(GMT-08:00) Pacific Time (US & Canada)', from: 'patient_time_zone')
    end
    click_button 'Save & Continue'

    @patient.reload
    assert_equal 'Pacific Time (US & Canada)', @patient.time_zone

    expect(page).must_have_content('What is your name and gender?')
    within("form#edit_patient_#{@patient.id}") do
      fill_in('patient_first_name', with: 'F_name')
      fill_in('patient_last_name', with: 'L_name')
      select('Female', from: 'patient_basic_detail_attributes_gender')
    end
    click_button 'Save & Continue'

    @patient.reload
    assert_equal 1, @patient.gender
  end

  def patient_signs_in
    authenticate_user(@patient, @params[:phone])
  end

  def patient_starts_wi(org, params)
    post v1_right_now_visit_path,
      headers: { "APP_TOKEN": org.api_token },
      params: params,
      xhr: true
    api_response = JSON.parse(response.body)
    assert api_response["message"] == 'Set up a visit'
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
