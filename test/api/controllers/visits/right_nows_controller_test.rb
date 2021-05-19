require "test_helper"
class RightNowsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper
  include OpenTokHelper
  include TextMessageHelper

  setup do
    @uvo_health = organizations(:uvo_health)
    @rmg = organizations(:rmg)
    @patient = patients(:patient_20)
    @patient_1337 = patients(:patient_1337)
    @provider = providers(:provider_john)
    @coordinator = coordinators(:coordinator_46)
    stubs_open_tok_create_session
  end

  test "Visit POST - creates a new RIGHT NOW visit" do
    stubs_text_message_send_text
    post v1_right_now_visit_path,
        headers: { "APP_TOKEN": @uvo_health.api_token },
        params: {
          "patient_notes": "This is a new test visit.",
          "patient_id": 44,
        },
        xhr: true
    @api_response = JSON.parse(response.body)
    assert_equal "Visit Created", @api_response["message"]
    assert_equal Visit.last.id, @api_response["visit"]["id"]
  end

  test "WI visit - existing patient" do
    authentication = Authentication.for @patient.phone
    authentication.create_token skip_notifications: true
    path = new_visit_short_url(i: authentication.id, c: authentication.token, u: @patient.id)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, ["Click on #{path} to set up a visit", @patient.phone])

    options = {
      headers: { "APP_TOKEN": @rmg.api_token },
      params: {
        "phone": @patient.phone,
        "client_unique_id": "123456789"
      },
      xhr: true
    }
    TextMessage.stub(:send_text, mock) do
      assert_difference "Patient.count", 0 do
        post v1_right_now_visit_path, options
      end
    end
    assert_mock mock
    resp = JSON.parse(response.body)
    assert_equal "Set up a visit", resp["message"]
  end

  test "WI visit - existing patients with same phone" do
    stubs_text_message_send_text
    options = {
      headers: { "APP_TOKEN": @uvo_health.api_token },
      params: {
        "phone": @patient_1337.phone,
        "client_unique_id": "123456789"
      },
      xhr: true
    }

    assert_difference "Patient.count", 0 do
      post v1_right_now_visit_path, options
    end

    resp = JSON.parse(response.body)
    assert_equal "You must send user_id in request params to find patient among these.", resp["message"]
    assert_equal [147, 1337], resp["users"].sort

    options[:params][:user_id] = 147


    assert_difference "Patient.count", 0 do
      post v1_right_now_visit_path, options
    end

    resp = JSON.parse(response.body)
    assert_equal "Set up a visit", resp["message"]
  end

  test "WI visit - new patient" do
    phone = "5105100033"
    stubs_text_message_send_text
    options = {
      headers: { "APP_TOKEN": @uvo_health.api_token },
      params: {
        "phone": phone,
        "client_unique_id": "123456789"
      },
      xhr: true
    }

    assert_difference "Patient.count", 1 do
      post v1_right_now_visit_path, options
    end

    resp = JSON.parse(response.body)
    assert_equal "Set up a visit", resp["message"]

    last_patient = Patient.last
    assert_equal phone, last_patient.phone
  end

  test 'WI visit - Unauthorized for Organization with individual, practice or professional plans' do
    @uvo_health.individual!
    invalid_wi_visit_permission

    @uvo_health.professional!
    invalid_wi_visit_permission

    @uvo_health.practice!
    invalid_wi_visit_permission
  end

  test 'WI visit - Allowed for Organization with integrated and free full access plans' do
    @uvo_health.integrated!
    valid_wi_visit_permission

    @uvo_health.free_full_access!
    valid_wi_visit_permission
  end

  private

  def post_wi_visit
    phone = "5105100033"
    stubs_text_message_send_text
    options = {
      headers: { "APP_TOKEN": @uvo_health.api_token },
      params: {
        "phone": phone,
        "client_unique_id": "123456789"
      },
      xhr: true
    }

    post v1_right_now_visit_path, options
  end

  def invalid_wi_visit_permission
    post_wi_visit
    resp = JSON.parse(response.body)
    assert_equal "Unauthorized", resp["message"]
  end

  def valid_wi_visit_permission
    post_wi_visit
    resp = JSON.parse(response.body)
    assert_equal 'Set up a visit', resp["message"]
  end
end
