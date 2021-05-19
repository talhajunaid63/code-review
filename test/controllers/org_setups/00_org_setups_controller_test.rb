require "test_helper"
feature "OrgSetupsControllerTest" do
  include AuthenticationHelper

  scenario "new" do
    visit new_org_setup_path
    expect(page).must_have_content("Your Own Telemedicine Platform")
  end

  scenario "/setup routes to org_setups#new" do
    visit "/setup"
    expect(page).must_have_content("Your Own Telemedicine Platform")
  end

  scenario "create" do
    visit new_org_setup_path
    first(:link, "Get Started").click
    expect(page).must_have_content "Let's create your account!"
  end

  scenario "redirects if user is logged in" do
    skip
  end
end
