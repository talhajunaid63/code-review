require "test_helper"
class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @organization = organizations(:uvo_health)
  end

  test "Show - return organization basic details and settings" do
    get v1_organization_path(@organization.id),
        headers: {
          "APP_TOKEN": "test_001"
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @organization.name, response_json["name"]
    assert_equal "pooled", response_json["visit_settings"]["schedule_preference"]
    assert_equal 35, response_json["visit_settings"]["visit_rate"]
    assert_equal true, response_json["metadata_settings"]["address"]
    assert_equal true, response_json["video_call_settings"]["enabled"]
  end

end
