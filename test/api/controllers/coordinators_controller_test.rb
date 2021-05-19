require "test_helper"
class CoordinatorsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @coordinator_14 = coordinators(:coordinator_14)
    @coordinator_6 = coordinators(:coordinator_6)
    @org_admin = org_admins(:org_admin_michael)
  end

  test "Coordinator GET fails if not authenticated" do
    get v1_coordinator_path(@coordinator_14.id), xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json["message"] == "Unauthorized"
  end

  test "Coordinator can access its own details" do
    get v1_coordinator_path(@coordinator_14.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @coordinator_14.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @coordinator_14.phone, response_json["phone"]
  end

  test "Coordinator cannot access other coodinator's details" do
    get v1_coordinator_path(@coordinator_6.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @coordinator_14.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Org Admins can access details of coordinators within their organization" do
    get v1_coordinator_path(@coordinator_14.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @coordinator_14.phone, response_json["phone"]
  end

  test "Org Admins cannot access details of coordinators outside of their organization" do
    get v1_coordinator_path(@coordinator_6.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Coordinator can update its own details" do
    assert_equal "Cruz Turner", @coordinator_14.name
    patch_to_coordinator(
      @coordinator_14, {
        "coordinator": {
          "first_name": "Updated",
          "last_name": "Name"
        },
      }
    )
    response_json = JSON.parse(response.body)
    assert_equal "Coordinator updated", response_json["message"]
    @coordinator_14.reload
    assert_equal "Updated Name", @coordinator_14.name
  end

  test "Coordinator cannot update other coordinator's details" do
    patch v1_coordinator_path(@coordinator_6.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @coordinator_14.authentication_token
        },
        params: {
          "coordinator": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Org Admins can update details of coordinators within their organization" do
    patch v1_coordinator_path(@coordinator_14.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "coordinator": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert_equal "Coordinator updated", response_json["message"]
    @coordinator_14.reload
    assert_equal "Updated Name", @coordinator_14.name
  end

  test "Org Admins cannot update details of coordinators outside of their organization" do
    patch v1_coordinator_path(@coordinator_6.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "coordinator": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Create New Coordinator" do
    assert_difference 'Coordinator.count' do
      post v1_coordinators_path(
        "coordinator": {
          "email": "test_coordinator@coordinator.test"
        }),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    end
    response_json = JSON.parse(response.body)
    assert_equal response_json["message"], "Coordinator created"
    assert_equal "test_coordinator@coordinator.test", Coordinator.last.email
    assert_equal @org_admin.organization_id, Coordinator.last.organization_id
  end
end
