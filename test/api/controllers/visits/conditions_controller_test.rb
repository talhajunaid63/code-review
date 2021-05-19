require "test_helper"
class ConditionsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @visit = visits(:visit_1)
    @patient = patients(:patient_1)
  end

  test "Index" do
    get v1_visit_conditions_path(@visit),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 1, response_json.length
    assert response_json.to_s.include? "Dignissimositus"
  end

  test "Create" do
    assert_equal 1, @visit.conditions.count
    post v1_visit_conditions_path(@visit),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        params: {
          "conditions": [
            { "name": "Arthritis" },
            { "name": "Hypertension" }
          ]
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response_json["message"] == "Conditions added to visit"
    assert_equal 3, @visit.conditions.count
  end

end
