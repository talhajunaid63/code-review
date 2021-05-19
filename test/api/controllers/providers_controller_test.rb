require "test_helper"
class ProvidersControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper
  include TextMessageHelper

  setup do
    @provider_antoine = providers(:provider_antoine)
    @provider_isreal = providers(:provider_isreal)
    @org_admin = org_admins(:org_admin_michael)
    stubs_text_message_send_text
  end

  test "Provider GET fails if not authenticated" do
    get v1_provider_path(@provider_antoine.id), xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json["message"] == "Unauthorized"
  end

  test "Provider can access its own details" do
    get v1_provider_path(@provider_antoine.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @provider_antoine.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @provider_antoine.phone, response_json["phone"]
  end

  test "Providers cannot access other provider's details" do
    get v1_provider_path(@provider_isreal.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @provider_antoine.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Org Admins can access details of providers within their organization" do
    get v1_provider_path(@provider_antoine.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @provider_antoine.phone, response_json["phone"]
  end

  test "Org Admins cannot access details of providers outside of their organization" do
    get v1_provider_path(@provider_isreal.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Provider can update its own details" do
    assert_equal "Antoine Ward", @provider_antoine.name
    patch_to_provider(
      @provider_antoine, {
        "provider": {
          "first_name": "Updated",
          "last_name": "Name"
        },
      }
    )
    response_json = JSON.parse(response.body)
    assert_equal response_json["message"], "Provider updated"
    @provider_antoine.reload
    assert_equal "Updated Name", @provider_antoine.name
  end

  test "Provider cannot update other provider's details" do
    patch v1_provider_path(@provider_isreal.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @provider_antoine.authentication_token
        },
        params: {
          "provider": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Org Admins can update details of providers within their organization" do
    patch v1_provider_path(@provider_antoine.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "provider": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert_equal response_json["message"], "Provider updated"
    @provider_antoine.reload
    assert_equal "Updated Name", @provider_antoine.name
  end

  test "Org Admins cannot update details of providers outside of their organization" do
    patch v1_provider_path(@provider_isreal.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "provider": {
            "first_name": "Updated",
            "last_name": "Name"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Create New Provider" do
    assert_difference 'Provider.count' do
      post v1_providers_path(
        "provider": {
          "email": "test_provider@provider.test"
        }),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    end
    response_json = JSON.parse(response.body)
    assert_equal 200, response.status
    assert_equal response_json["message"], "Provider created"
    assert_equal "test_provider@provider.test", Provider.last.email
    assert_equal @org_admin.organization_id, Provider.last.organization_id
  end
end
