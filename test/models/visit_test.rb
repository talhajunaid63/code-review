require "test_helper"

class VisitTest < ActiveSupport::TestCase

  setup do
    @org_admin = org_admins(:org_admin_michael)
    @rmg = organizations(:rmg)
    @southwest = organizations(:southwest_medical)
  end


  test "Organization self service test" do
    @rmg.visit_setting.update(self_service_enabled: false)
    assert @southwest.self_service_enabled? == true
    assert @rmg.self_service_enabled? == false
  end

  test "Organization schedule_preference test" do
    @visit_settings = @southwest.visit_settings.first
    @visit_settings.schedule_preference = :individually_scheduled
    @visit_settings.save
    @southwest.reload
    @southwest.schedule_preference == "pooled"
  end

end
