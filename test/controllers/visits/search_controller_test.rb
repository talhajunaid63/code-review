require "test_helper"
feature "VisitsSearchControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @coordinator = coordinators(:coordinator_14)
    @organization = organizations(:rmg)
    stubs_text_message_send_text
    apply_all_users_triggers
  end

  scenario "Visits Search - by patient's last name", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    search_for("Lowe")
    expect(page).must_have_content('2 Results Found for "Lowe"')
  end

  scenario "Visits Search - by internal notes", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    search_for("private")
    expect(page).must_have_content('1 Result Found for "private"')
  end

  scenario "Visits Search - clear Search returns to visits index", js: true do
    authenticate_user(@coordinator, @coordinator.phone)
    search_for("Lowe")
    expect(page).must_have_content('2 Results Found for "Lowe"')
    click_link "Clear Search"
    expect(page).must_have_content("Add a Scheduled Visit")
  end

  def search_for(q)
    visit organization_visits_path(@organization)
    within("form#visits_search") do
      fill_in("q", with: q)
      find('.search-form-button').click
    end
  end
end
