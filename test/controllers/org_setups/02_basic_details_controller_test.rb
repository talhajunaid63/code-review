require "test_helper"
feature "OrgSetupsBasicDetailsControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    StripeMock.start
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 4)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "new" do
    @org_count_before = Organization.all.count
    expect(page).must_have_content "Basic Details"
    within "#new_org_setup_basic_detail" do
      fill_in "org_setup_basic_detail_name", with: "Test Org"
      fill_in "org_setup_basic_detail_description", with: "Test Description Goes Here"
      fill_in "org_setup_basic_detail_zip", with: "90210"
      fill_in "org_setup_basic_detail_phone", with: "5558015555"
      click_button "Create Organization"
    end
    assert_equal @org_count_before + 1, Organization.all.count

    auth = Authentication.for(@phone.delete("^0-9"))
    @org_admin = auth.users.last
    assert_equal Organization.last.id, @org_admin.organization_id
  end

  scenario "invalid data produces error messages" do
    @org_count_before = Organization.all.count
    within "#new_org_setup_basic_detail" do
      fill_in "org_setup_basic_detail_name", with: ""
      fill_in "org_setup_basic_detail_description", with: "Test Description Goes Here"
      fill_in "org_setup_basic_detail_zip", with: "90210"
      fill_in "org_setup_basic_detail_phone", with: "5558015555"
      click_button "Create Organization"
    end
    assert_equal @org_count_before, Organization.all.count
    expect(page).must_have_content "Name can't be blank"
  end
end
