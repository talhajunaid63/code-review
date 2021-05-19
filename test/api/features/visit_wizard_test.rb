require "test_helper"
class VisitWizardTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper
  include OpenTokHelper
  include ApiHelper

  setup do
    @user = patients(:patient_1)
    stubs_open_tok_create_session
  end

  test "Visit creation wizard steps" do
    # Create a new visit
    post v1_visits_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @user.authentication_token
        },
        params: {
          "patient_notes": "This is a new test visit."
        },
        xhr: true
    @api_response = JSON.parse(response.body)

    assert_equal @api_response["message"], "Visit Created"

    # Update Medications
    post v1_medications_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @user.authentication_token
        },
        params: {
          "medications": [
            { "name": "Penacilyn", "how_long": "Two Months" },
            { "name": "Amoxacylin", "how_long": "Three Weeks" }
          ]
        },
        xhr: true
    @api_response = JSON.parse(response.body)
    assert_equal @api_response["message"], "Medications added to user"

    # Update Conditions or Considerations

    patch_to_patient(
      @user,
      "patient": {
        "basic_detail_attributes": {
          "conditions": "I am allergic to penicillin and I have a slight case of asthma"
        }
      },
    )
    assert response.body.include? "Patient Updated"

    # View Schedule
    get v1_available_times_path,
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @user.authentication_token
        },
        xhr: true
    assert response.body.include? "time_until"

    # Update visit with selected schedule

    # Confirm Visit
  end

end
