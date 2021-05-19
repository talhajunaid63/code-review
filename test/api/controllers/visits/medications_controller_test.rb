require "test_helper"
class MedicationsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @visit = visits(:visit_1)
    @patient = patients(:patient_1)
  end

  test "Index" do
    get v1_visit_medications_path(@visit),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 3, response_json.length
    assert response_json.to_s.include? "quibusdamix"
  end

  test "Create" do
    assert_equal 3, @visit.medications.count
    post v1_visit_medications_path(@visit),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient.authentication_token
        },
        params: {
          "medications": [
            { "name": "Penacilyn", "how_long": "Two Months" },
            { "name": "Amoxacylin", "how_long": "Three Weeks" }
          ]
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response_json["message"] == "Medications added to visit"
    assert_equal 5, @visit.medications.count
  end

end
