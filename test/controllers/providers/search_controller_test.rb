require "test_helper"
feature "ProvidersSearchControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @acts_as_org_admin_coordinator = coordinators(:coordinator_14)
    @coordinator = coordinators(:coordinator_16)
    @organization = organizations(:rmg)
    stubs_text_message_send_text
    apply_all_users_triggers
  end

  scenario "Providers Search - with results", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("huels")
    expect(page).must_have_content('1 Result Found for "huels"')
  end

  scenario "Providers Search - search by full name", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("Carissa Huels")
    expect(page).must_have_content('1 Result Found for "Carissa Huels"')
  end

  scenario "Providers Search - with results by zip", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("91042")
    expect(page).must_have_content('7 Results Found for "91042"')
  end

  scenario "Providers Search - without results", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("Joe")
    expect(page).must_have_content('0 Results Found for "Joe"')
  end

  scenario "Providers Search - clear Search returns to providers index", js: true do
    authenticate_user(@acts_as_org_admin_coordinator, @acts_as_org_admin_coordinator.phone)
    search_for("huels")
    expect(page).must_have_content('1 Result Found for "huels"')
    click_link "Clear Search"
    expect(page).must_have_content("Add New Provider")
  end

  def search_for(q)
    visit organization_providers_path(@organization)
    within("form#providers_search") do
      fill_in("q", with: q)
      page.execute_script("$('.search-form-button').click()")
    end
  end
end
