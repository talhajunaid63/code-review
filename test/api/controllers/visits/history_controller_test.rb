require "test_helper"
class VisitsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @patient = patients(:patient_20)
    @org_admin = org_admins(:org_admin_michael)
  end

  test "successfully returns visits history/report" do
    post history_v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "from": (Date.today - 60.days).to_s,
          "to": Date.today.to_s
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 14, response_json.length
  end

  test "from and to dates must be present and valid" do
    post history_v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 400
    assert_equal "From and To dates must be present and valid", response_json["message"]
  end

  test "only availalbe/accesible for org admins" do
    post history_v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Authenticated Org Admin is required", response_json["message"]
  end

end
