require "test_helper"
feature "PatientsSearchControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @acts_as_org_admin_coordinator = coordinators(:coordinator_14)
    @coordinator = coordinators(:coordinator_16)
    @organization = organizations(:rmg)
    stubs_text_message_send_text
    apply_all_users_triggers
  end

  scenario "Patients Search - with results", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("lowe")
    expect(page).must_have_content('1 Result Found for "lowe"')
  end

  scenario "Patients Search - search by full name", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("Anthony Lowe")
    expect(page).must_have_content('1 Result Found for "Anthony Lowe"')
  end

  scenario "Patients Search - with results by zip", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("93001")
    expect(page).must_have_content('18 Results Found for "93001"')
  end

  scenario "Patients Search - without results", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("Joe")
    expect(page).must_have_content('0 Results Found for "Joe"')
  end

  scenario "Patients Search - clear Search returns to patients index", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("lowe")
    expect(page).must_have_content('1 Result Found for "lowe"')
    click_link "Clear Search"
    expect(page).must_have_content("Add New Patient/Client")
  end

  def search_for(q)
    visit organization_patients_path(@organization)
    within("form#patients_search") do
      fill_in("q", with: q)
      find('.search-form-button').click
    end
  end
end
