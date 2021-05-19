require "test_helper"
class PingsControllerTest < ActionDispatch::IntegrationTest
  test "Baisc Ping" do
    get v1_ping_path, xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json["message"] == "All Systems Go!"
  end

  test "Ping API Token" do
    post v1_ping_app_token_path,
        headers: { "APP_TOKEN": "test_001" },
        xhr: true

    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json["message"] == "SUCCESS!"
  end
end
