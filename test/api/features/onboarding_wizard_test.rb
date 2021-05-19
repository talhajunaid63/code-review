require "test_helper"
class OnboardingWizardTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper
  include ApiHelper
  include TextMessageHelper

  setup do
    @new_valid = "661-388-5848"
    #TODO remove this step in the future - for now only allow login for backend created accounts
    @user = Patient.create(phone: @new_valid)
    stubs_text_message_send_text
  end

  test "Basic Onboarding Steps" do
    # Create account - get authentication token
    response = api_request_token(@new_valid)
    puts response["message"]
    @user = Patient.find_by_authentication_token(@user.authentication_token)
    # Update account with Zip
    response = patch_to_patient(
      @user,
      "patient": {
        "zip": "93001"
      },
    )
    # Update account with DOB
    patch_to_patient(
      @user,
      "patient": {
        "basic_detail_attributes": {
          "dob_d": "06",
          "dob_m": "12",
          "dob_y": "1988"
        }
      },
    )
    # Update account with name and gender
    patch_to_patient(
      @user,
      "patient": {
        "first_name": "John",
        "last_name": "Salz",
        "basic_detail_attributes": {
          "gender": "0"
        }
      },
    )
    # User object confirmed
    @user.reload
    assert_equal 32, @user.age
    assert_equal "John", @user.first_name
    assert_equal "93001", @user.zip
    assert_equal "Male", @user.gender_text
  end
end
