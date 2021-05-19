require "test_helper"
feature "VistMetadataSettingsControllerTest" do
  include AuthenticationHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @patient = patients(:patient_1)
    stubs_open_tok_create_session
    stubs_text_message_send_text
  end

  scenario "Index creates and displays metadata settings" do
    authenticate_user(@org_admin, @org_admin.phone)
    assert_equal 1, @organization.visit_settings.count
    visit organization_metadata_settings_path(@organization)
    expect(page).must_have_content("Edit Patient/Client Data Settings")
    assert_equal 1, @organization.metadata_settings.count
  end

  scenario "Update metadata settings" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_metadata_settings_path(@organization)
    expect(page).must_have_content("Edit Patient/Client Data Settings")
    assert_equal true, @organization.data_settings.address
    assert_equal true,  @organization.data_settings.dob
    assert_equal true, @organization.data_settings.reference_number
    assert_equal false, @organization.data_settings.incident_information
    metadata_setting = @organization.metadata_settings.first
    within("form#edit_metadata_setting_#{metadata_setting.id}") do
      find(:css, "#metadata_setting_address").set(false)
      find(:css, "#metadata_setting_dob").set(false)
      find(:css, "#metadata_setting_reference_number").set(false)
      find(:css, "#metadata_setting_incident_information").set(true)
      click_button "Save Settings"
    end
    metadata_setting.reload
    assert_equal false, @organization.data_settings.address
    assert_equal false,  @organization.data_settings.dob
    assert_equal false, @organization.data_settings.reference_number
    assert_equal true, @organization.data_settings.incident_information
  end

  scenario "Revising metadata settings changes edit view for admin users" do
    authenticate_user(@org_admin, @org_admin.phone)
    patient = @organization.patients.last

    visit edit_organization_patient_path(@organization, patient)
    expect(page).must_have_content("Address")
    expect(page).must_have_content("Date of Birth")
    expect(page).must_have_content("Reference Number")

    metadata_setting = MetadataSetting.find_or_create_by(organization_id: @organization.id)
    metadata_setting.update(address: false, dob: false, reference_number: false)

    visit edit_organization_patient_path(@organization, patient)
    expect(page).wont_have_content("Address")
    expect(page).wont_have_content("Date of Birth")
    expect(page).wont_have_content("Reference Number")
  end

  scenario "Revising metadata settings changes progress indicator in visit builder" do
    authenticate_user(@patient, @patient.phone)
    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("Step 1 of 4")
    expect(page).must_have_content("What brings you in today?")

    metadata_setting = MetadataSetting.find_or_create_by(organization_id: @organization.id)
    metadata_setting.update(visit_notes: false)

    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("Step 1 of 3")
    expect(page).must_have_content("Medical Details")
  end

  scenario "Revising metadata settings changes edit view for patients while setting up a new visit" do
    authenticate_user(@patient, @patient.phone)

    metadata_setting = MetadataSetting.find_or_create_by(organization_id: @organization.id)
    metadata_setting.update!(visit_notes: false, incident_information: true)

    visit_setting = VisitSetting.find_or_create_by(organization_id: @organization.id)
    visit_setting.update!(self_service_enabled: true)

    visit new_organization_visit_path(@patient.organization.slug, patient_id: @patient.id)
    expect(page).must_have_content("Step 1 of 3")
    expect(page).must_have_content("Medical Details")
    expect(page).must_have_content("Medications")
    expect(page).must_have_content("Conditions or Considerations")
    expect(page).wont_have_content("Workplace Incident Information")

    metadata_setting.update(conditions: false, medications: true)

    visit current_path
    expect(page).must_have_content("Medical Details")
    expect(page).must_have_content("Medications")
    expect(page).wont_have_content("Conditions or Considerations")

    metadata_setting.update(conditions: true, medications: false)

    visit current_path
    expect(page).must_have_content("Medical Details")
    expect(page).wont_have_content("Medications")
    expect(page).must_have_content("Conditions or Considerations")

    metadata_setting.update(conditions: false, medications: false)

    visit current_path
    expect(page).must_have_content("Step 1 of 2")
    expect(page).must_have_content("Schedule")
    expect(page).wont_have_content("Medications")
    expect(page).wont_have_content("Conditions or Considerations")
  end

  scenario "Revising metadata settings changes progress indicator in patient builder" do
    patient = patients(:patient_44)
    authenticate_user(patient, patient.phone)
    visit organization_patient_build_path(:zip, organization_id: patient.organization.slug, patient_id: patient.id)
    expect(page).must_have_content("Step 1 of 4")

    metadata_setting = MetadataSetting.find_or_create_by(organization_id: patient.organization.id)
    metadata_setting.update(dob: false)

    visit organization_patient_build_path(:zip, organization_id: patient.organization.slug, patient_id: patient.id)
    expect(page).must_have_content("Step 1 of 3")
  end
end
