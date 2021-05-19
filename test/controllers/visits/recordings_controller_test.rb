require "test_helper"
class Visits::RecordingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @organization = organizations(:uvo_health)
    @visit = visits(:visit_8)
    VisitRecording.delete_all
  end

  test "Create - creates a new visit recording when OpenTok hits our callback url" do
    assert_equal 0, @organization.visit_recordings.count

    post recordings_path,
        headers: {
          "APP_TOKEN": "test_001"
        },
        params: {
          "id": "1ca77970-b701-4f6f-bc8f-1c10423848dc",
          "event": "archive",
          "createdAt": 1576930668000,
          "duration": 328,
          "name": "Foo",
          "partnerId": 123456,
          "reason": "",
          "resolution": "640x480",
          "sessionId": "tok_8_tok_8",
          "size": 18023312,
          "status": "uploaded",
          "url": nil
        },        
        xhr: true
    assert_equal 200, response.status

    assert_equal 1, @organization.visit_recordings.count
    last_recording = VisitRecording.last
    assert_equal "1ca77970-b701-4f6f-bc8f-1c10423848dc", last_recording.tok_id
    assert_equal "tok_8_tok_8", last_recording.tok_session_id
    assert_equal @organization.id, last_recording.organization_id
    assert_equal @visit.id, last_recording.visit_id
  end

  test "Create - only creates a new visit recording when status is uploaded" do
    assert_equal 0, @organization.visit_recordings.count

    post recordings_path,
        headers: {
          "APP_TOKEN": "test_001"
        },
        params: {
          "id": "1ca77970-b701-4f6f-bc8f-1c10423848dc",
          "event": "archive",
          "createdAt": 1576930668000,
          "duration": 328,
          "name": "Foo",
          "partnerId": 123456,
          "reason": "",
          "resolution": "640x480",
          "sessionId": "tok_8_tok_8",
          "size": 18023312,
          "status": "started",
          "url": nil
        },        
        xhr: true
    assert 200, response.status

    assert_equal 0, @organization.visit_recordings.count
  end  

end
