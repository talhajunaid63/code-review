require "test_helper"
class PatientsControllerTest < ActionDispatch::IntegrationTest
  include ApiHelper

  setup do
    @patient_1 = patients(:patient_1)
    @org_admin = org_admins(:org_admin_michael)

    @patient_20 = patients(:patient_20)
    @patient_44 = patients(:patient_44)
  end

  test "Patient GET fails if not authenticated" do
    get v1_patient_path(@patient_1.id), xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json["message"] == "Unauthorized"
  end

  test "Patient can access its own details" do
    get v1_patient_path(@patient_1.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient_1.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert_equal @patient_1.id, response_json["id"]
    assert_equal @patient_1.organization_id, response_json["organization_id"]
  end

  test "Patients details include metadata settings" do
    get v1_patient_path(@patient_1.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient_1.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json.to_s.include? "metadata_settings"
  end

  test "Patients cannot access other patient's details" do
    get v1_patient_path(@patient_1.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient_20.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end
  
  test "Org Admins can access details of patients within their organization" do
    get v1_patient_path(@patient_1.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 200
    assert response_json.to_s.include? "metadata_settings"
  end

  test "Org Admins cannot access details of patients outside of their organization" do
    get v1_patient_path(@patient_44.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end  

  test "Patient Update name" do
    assert @patient_1.first_name == "Anthony"
    patch_to_patient(
      @patient_1,
      "patient": {
        "first_name": "Jack"
      },
    )
    response_json = JSON.parse(response.body)
    assert response_json["message"] == "Patient Updated"
    @patient_1.reload
    assert @patient_1.first_name == "Jack"
  end

  test "User Update Zip" do
    assert_equal "93001", @patient_1.zip
    patch_to_patient(
      @patient_1,
      "patient": {
        "zip": 91384
      },
    )
    response_json = JSON.parse(response.body)
    assert response_json["message"] == "Patient Updated"
    @patient_1.reload
    assert "91384", @patient_1.zip
  end  

  test "Patient cannot update other patient's details" do
    patch v1_patient_path(@patient_20.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @patient_1.authentication_token
        },
        params: {
          "patient": {
            "first_name": "Jack"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Org Admins can update details of patients within their organization" do
    patch v1_patient_path(@patient_1.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "patient": {
            "first_name": "Jack"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response_json["message"] == "Patient Updated"
    @patient_1.reload
    assert @patient_1.first_name == "Jack"
  end

  test "Org Admins cannot update details of patients outside of their organization" do
    patch v1_patient_path(@patient_44.id),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        params: {
          "patient": {
            "first_name": "Jack"
          },
        },
        xhr: true
    response_json = JSON.parse(response.body)
    assert response.status == 401
    assert_equal "Unauthorized", response_json["message"]
  end

  test "Create New Patient" do
    assert_difference 'Patient.count' do
      post v1_patients_path(
        "patient": {
          "email": "test_patient@patient.test"
        }),
        headers: {
          "APP_TOKEN": "test_001",
          "AUTH_TOKEN": @org_admin.authentication_token
        },
        xhr: true
    end

    response_json = JSON.parse(response.body)
    assert_equal 200, response.status
    assert_equal "Patient created", response_json["message"]
    assert_equal "test_patient@patient.test", Patient.last.email
    assert_equal @org_admin.organization_id, Patient.last.organization_id
  end
end
