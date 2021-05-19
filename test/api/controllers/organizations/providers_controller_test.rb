require "test_helper"
class PatientsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @organization = organizations(:uvo_health)
  end

  test "Index - list all organization's providers" do
    get v1_organization_providers_path(@organization.id),
        headers: {
          "APP_TOKEN": "test_001"
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 2, response_json.length
    assert response_json.to_s.include? "Janet Whitehouse"
  end

end
