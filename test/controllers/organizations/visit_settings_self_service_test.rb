require "test_helper"
feature "VistSettingsSelfServiceTest" do
  include AuthenticationHelper
  setup do
    @org_admin = org_admins(:org_admin_michael)
    @organization_no_self_service = organizations(:rmg)
    @organization_with_self_service = organizations(:southwest_medical)
  end

  scenario "Self service NOT enabled should NOT have create account prompt" do
    @organization_no_self_service.visit_setting.update(self_service_enabled: false)
    expect @organization_no_self_service.self_service_enabled? == false
    visit organization_path(@organization_no_self_service)
    expect(page).wont_have_content("Sign up")
  end

  scenario "Self service enabled should have create account prompt" do
    expect @organization_with_self_service.self_service_enabled? == true
    visit organization_path(@organization_with_self_service)
    expect(page).must_have_content("Sign up")
  end
end
