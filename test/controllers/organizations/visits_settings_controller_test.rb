require "test_helper"
feature "VisitsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    stubs_text_message_send_text
  end

  scenario "Index creates and displays visit settings" do
    authenticate_user(@org_admin, @org_admin.phone)
    @organization.visit_settings.destroy_all
    assert_equal 0, @organization.visit_settings.count
    visit organization_visit_settings_path(@organization)
    expect(page).must_have_content("Edit Visit Settings")
    assert_equal 1, @organization.visit_settings.count
  end

  scenario "Update" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_visit_settings_path(@organization)
    expect(page).must_have_content("Edit Visit Settings")
    visit_setting = @organization.visit_settings.first
    assert_equal 35, visit_setting.visit_rate
    assert_equal false, visit_setting.require_payment
    assert_equal true, visit_setting.pooled?
    assert_equal false, visit_setting.auth_number_required
    within("form#edit_visit_setting_#{visit_setting.id}") do
      select("Require Payment Method", from: "visit_setting_require_payment")
      select("Yes - Require Auth Number", from: "visit_setting_auth_number_required")
      select("Scheduled with individual providers", from: "visit_setting_schedule_preference")
      fill_in("visit_setting_visit_rate", with: "15")
      click_button "Save Settings"
    end
    visit_setting.reload
    assert_equal 15, visit_setting.visit_rate
    assert_equal true, visit_setting.require_payment
    assert_equal false, visit_setting.pooled?
    assert_equal true, visit_setting.individually_scheduled?
    assert_equal true, visit_setting.auth_number_required
  end

  scenario "Auth Number Not Required - New visit does not require Auth Number field" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_visits_path(@organization)
    click_link "Add a Scheduled Visit"
    expect(page).wont_have_content("Auth Number*")
  end

  scenario "Auth Number Required - New visit requires Auth Number field" do
    visit_setting = VisitSetting.find_or_create_by(organization_id: @organization.id)
    visit_setting.auth_number_required = true
    visit_setting.save

    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_visits_path(@organization)
    click_link "Add a Scheduled Visit"
    expect(page).must_have_content("Auth Number*")
  end

end
