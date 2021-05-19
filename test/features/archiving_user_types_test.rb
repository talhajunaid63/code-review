require "test_helper"
feature "ArchivingUserTypesTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @patient = patients(:patient_20)
    @provider = providers(:provider_antoine)
    @coordinator = coordinators(:coordinator_14)
    stubs_text_message_send_text
  end

  scenario "OrgAdmin can archive a Patient" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit edit_organization_patient_path(@organization, @patient)
    click_link "Archive Patient"
    expect(page).must_have_content("Patient Archived")
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@patient.name)
  end

  scenario "OrgAdmin can unarchive a Patients" do
    @patient.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@patient.name)
    click_link "Unarchive"
    expect(page).wont_have_content(@patient.name)
    expect(page).must_have_content("No Archived Users")
  end

  scenario "Archived Patients are hidden from index view" do
    @patient.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_patients_path(@organization)
    expect(page).must_have_content("1 2 Next")
    expect(page).wont_have_content(@patient.name)
    click_link "2"
    expect(page).wont_have_content(@patient.name)
  end

  scenario "OrgAdmin can archive a Provider" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit edit_organization_provider_path(@organization, @provider)
    click_link "Archive Provider"
    expect(page).must_have_content("Provider Archived")
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@provider.name)
  end

  scenario "OrgAdmin can unarchive a Provider" do
    @provider.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@provider.name)
    click_link "Unarchive"
    expect(page).wont_have_content(@provider.name)
    expect(page).must_have_content("No Archived Users")
  end

  scenario "Archived Providers are hidden from index view" do
    @provider.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_providers_path(@organization)
    expect(page).wont_have_content("Next")
    expect(page).wont_have_content(@provider.name)
  end

  scenario "OrgAdmin can archive a Coordinator" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit edit_organization_coordinator_path(@organization, @coordinator)
    click_link "Archive Coordinator"
    expect(page).must_have_content("Coordinator Archived")
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@coordinator.name)
  end

  scenario "OrgAdmin can unarchive a Coordinator" do
    @coordinator.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_archived_users_path(@organization)
    expect(page).must_have_content(@coordinator.name)
    click_link "Unarchive"
    expect(page).wont_have_content(@coordinator.name)
    expect(page).must_have_content("No Archived Users")
  end

  scenario "Archived Coordinators are hidden from index view" do
    @coordinator.archive!
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_coordinators_path(@organization)
    expect(page).wont_have_content("Next")
    expect(page).wont_have_content(@coordinator.name)
  end

end
