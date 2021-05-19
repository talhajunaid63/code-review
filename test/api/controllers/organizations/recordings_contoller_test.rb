require "test_helper"
class RecordingsContollerTest < ActionDispatch::IntegrationTest
  include ApiHelper
  include S3ServiceHelper

  setup do
    @organization = organizations(:uvo_health)
    @recording = visit_recordings(:visit_recording_2)
    stubs_generate_presigned_url
  end

  test "Index - list all organization's recordings" do
    get v1_organization_recordings_path(@organization.id),
        headers: {
          "APP_TOKEN": "test_001"
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 2, response_json.length
    assert response_json['recordings'].to_s.include? 'Steve Thomas'
  end

  test 'Index - show unautorized message' do
    @organization.update(tier: 'individual')

    get v1_organization_recordings_path(@organization.id),
        headers: {
          "APP_TOKEN": "test_001"
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 1, response_json.length
    assert response_json.to_s.include? "You are not authorized to perform this action."
  end

  test 'Show - retrieve a single recording' do
    get v1_organization_recording_path(@organization.id, @recording.id),
        headers: {
          "APP_TOKEN": "test_001"
        },
        xhr: true

    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal 14, response_json.length
    assert response_json.to_s.include? "video_url"
  end
end
