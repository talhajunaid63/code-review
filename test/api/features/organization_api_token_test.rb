require "test_helper"
class OrganizationApiTokenTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper, ApiHelper

  setup do
    @uvo_health = organizations(:uvo_health)
    @southwest_medical = organizations(:southwest_medical)
  end

  test "allows to inteact with API endpoints" do
    get v1_patients_path,
        headers: { "APP_TOKEN": @uvo_health.api_token },
        xhr: true
    json_response = JSON.parse(response.body)
    assert_equal 200, response.status
    assert_equal 5, json_response.length
  end

  test "only works for organizations with a least one org admin" do
    get v1_patients_path,
    headers: { "APP_TOKEN": @southwest_medical.api_token },
    xhr: true
    json_response = JSON.parse(response.body)
    assert_equal 401, response.status
    assert json_response["message"] == "Before being able to interact with UvoHealth API you need to add an Admin to your Organization"
  end

end
