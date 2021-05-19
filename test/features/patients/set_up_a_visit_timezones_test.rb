require "test_helper"
feature "PatientSetUpAVisitTimezonesTest" do
  include AuthenticationHelper
  include PaymentHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @organization = organizations(:rmg)
    @patient_pt_tz = patients(:patient_1)
    @patient_ct_tz = patients(:patient_20)
    @patient_et_tz = patients(:patient_21)

    visit_settings = VisitSetting.find_or_create_by(organization_id: @organization.id)
    visit_settings.update(require_payment: true)


    # We travel to next week Wednesday
    Delorean.time_travel_to Date.today.next_week.advance(:days=>2)

    # First interval - time available - for a visit
    # is from provider Antoine Ward with Central Time (US & Canada)
    # So, first interval - available time - for a visit is:
    # 8:00 PM for provider at Central Time (US & Canada)
    # 6:00 PM for a patient at Pacific Time (US & Canada)
    # 8:00 PM for a patient at Central Time (US & Canada)
    # 9:00 PM for a patient at Eastern Time (US & Canada)
    first_interval = AvailableTimes::Intervals::FindService.new(@organization.providers_available_times).perform.first
    assert_equal "Antoine Ward", first_interval.provider.name
    assert_equal "Central Time (US & Canada)", first_interval.provider.time_zone
    assert first_interval.base_datetime_in_schedule_format.to_s.include? "8:00 PM"
    stubs_text_message_send_text
  end

  scenario "Set up a visit feature displays times in Pacific Time (US & Canada)" do
    stubs_open_tok_create_session

    authenticate_user(@patient_pt_tz, @patient_pt_tz.phone)
    visit new_organization_visit_path(@patient_pt_tz.organization.slug, patient_id: @patient_pt_tz.id)
    visit = Visit.last

    fill_patient_notes_form(visit)
    fill_medication_form(visit)
    fill_conditions_form(visit)
    click_button "Save & Continue"

    expect(page).must_have_content("Schedule")
    select_first_available_time

    expect(page).must_have_content("6:00 PM")

    Delorean.back_to_the_present
  end

  scenario "Set up a visit feature displays times in Central Time (US & Canada)" do
    stubs_open_tok_create_session
    authenticate_user(@patient_ct_tz, @patient_ct_tz.phone)
    visit new_organization_visit_path(@patient_ct_tz.organization.slug, patient_id: @patient_ct_tz.id)
    visit = Visit.last

    fill_patient_notes_form(visit)
    fill_medication_form(visit)
    fill_conditions_form(visit)
    click_button "Save & Continue"

    expect(page).must_have_content("Schedule")
    select_first_available_time

    expect(page).must_have_content("8:00 PM")

    Delorean.back_to_the_present
  end

  scenario "Set up a visit feature displays times in Eastern Time (US & Canada)" do
    stubs_open_tok_create_session
    authenticate_user(@patient_et_tz, @patient_et_tz.phone)
    visit new_organization_visit_path(@patient_et_tz.organization.slug, patient_id: @patient_et_tz.id)
    visit = Visit.last

    fill_patient_notes_form(visit)
    fill_medication_form(visit)
    fill_conditions_form(visit)
    click_button "Save & Continue"

    expect(page).must_have_content("Schedule")
    select_first_available_time

    expect(page).must_have_content("9:00 PM")

    Delorean.back_to_the_present
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
