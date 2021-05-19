require "test_helper"
class VisitsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper
  include OpenTokHelper

  setup do
    @uvo_health = organizations(:uvo_health)
    @patient = patients(:patient_20)
    @provider = providers(:provider_john)
    @coordinator = coordinators(:coordinator_14)
    stubs_open_tok_create_session
  end

  test "User GET - patient" do
    get v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert_equal response.status, 200
    assert_equal 1, response_json.length
    assert response_json.to_s.include? @patient.name
    assert response_json.to_s.include? "open_tok"
  end

  test "User GET - provider" do
    get v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @provider.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert_equal response.status, 200
    assert_equal 7, response_json.length
    assert response_json.to_s.include? "open_tok"
  end

  test "User GET - coordinator" do
    get v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @coordinator.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert_equal response.status, 200
    assert_equal 1, response_json.length
    assert response_json.to_s.include? "open_tok"
  end

  test "Visit POST - Patient creates a new visit " do
    post v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        params: {
          "patient_notes": "This is a new test visit."
        },
        xhr: true
    @api_response = JSON.parse(response.body)

    assert_equal @api_response["message"], "Visit Created"
  end

  test "Visit POST - creates a new visit via organization app token" do
    post v1_visits_path,
        headers: { "APP_TOKEN": @uvo_health.api_token },
        params: {
          "patient_notes": "This is a new test visit.",
          "patient_id": 44
        },
        xhr: true
    @api_response = JSON.parse(response.body)

    assert_equal @api_response["message"], "Visit Created"
  end

end
