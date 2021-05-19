require "test_helper"
class AuthentiationTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper, ApiHelper, ActiveJob::TestHelper, TextMessageHelper


  setup do
    Authentication.delete_all
    @exisiting_valid_phone = "5551115555"
    @exisiting_valid_email = "patient_1@fake.me"
    @case_sensitivity_email = "patiENT_1@Fake.me"
    @invalid_phone = "123-45-67"
    @invalid_email = "patienfake.me"
    @existing_user = patients(:patient_1)
    @existing_user_sharing_phone = patients(:patient_1338)
    @test_token = '12345'
    stubs_text_message_send_text
  end

  test "By phone - Request a Token Valid Existing" do
    response = api_request_token(@existing_user.phone)
  end

  test "By email - Request a Token Valid Existing" do
    response = api_request_token(@existing_user.email)
    assert_equal "Token Sent", response["message"]
  end

  test "By phone - Request a Token Invalid Number" do
    response = api_request_token(@invalid_phone)
    assert_equal "Phone/Email not found", response["message"]
  end

  test "By phone - Authenticate a Token Valid" do
    api_request_token(@exisiting_valid_phone)
    response = api_authenticate_token(@exisiting_valid_phone, @test_token)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user.authentication_token, response["authentication_token"]
  end

  test "By email - Authenticate a Token Valid" do
    api_request_token(@exisiting_valid_email)
    response = api_authenticate_token(@exisiting_valid_email, @test_token)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user.authentication_token, response["authentication_token"]
  end

  test "By email - Login with email is NOT case-sensitive" do
    api_request_token(@case_sensitivity_email)
    response = api_authenticate_token(@exisiting_valid_email, @test_token)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user.authentication_token, response["authentication_token"]
  end

  test "By phone - Authenticate a Token Test Account" do
    api_request_token(@existing_user.phone)
    response = api_authenticate_token(@exisiting_valid_phone, @test_token)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user.authentication_token, response["authentication_token"]
  end

  test "By phone - Authenticate a Token Test Account with multiple users" do
    api_request_token(@existing_user_sharing_phone.phone)
    response = api_authenticate_token(@existing_user_sharing_phone.phone, @test_token)
    assert_equal "Multiple users found. Need to also pass user_id parameter.", response["message"]
    assert_equal [1338, 1339], response["users"].map { |user| user["id"] }.sort
    response = api_authenticate_token(@existing_user_sharing_phone.phone, @test_token, user_id: 1338)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user_sharing_phone.authentication_token, response["authentication_token"]
  end

  test "By email - Authenticate a Token Test Account" do
    api_request_token(@existing_user.email)
    response = api_authenticate_token(@exisiting_valid_email, @test_token)
    assert_equal "User Signed In", response["message"]
    assert_equal @existing_user.authentication_token, response["authentication_token"]
    assert_equal @existing_user.organization_id, response["organization_id"]
  end

  test "By phone - Authenticate a Token Invalid number" do
    response = api_request_token(@invalid_phone)
    assert_equal "Phone/Email not found", response["message"]
  end

  test "By email - Authenticate a Token Invalid email" do
    response = api_request_token(@invalid_email)
    assert_equal "Phone/Email not found", response["message"]
  end
end
