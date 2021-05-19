require "test_helper"
class OrganizationImportsControllerTest <  ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActionDispatch::TestProcess
  tests Organizations::PatientImportsController

  def setup
    @organization = organizations(:rmg)
    @org_admin = org_admins(:org_admin_michael)
    session[:user_id] = @org_admin.id
  end

  test "Valid file is uploaded" do
    count_before = Patient.all.count
    valid_file = fixture_file_upload(
      "../fixtures/files/valid_patient_import.csv",
      "text/csv"
    )

    post :create, params: {
      organization_patient_import: {
        csv_file: valid_file,
        organization_id: @organization.id
      },
      organization_id: @organization.friendly_id
    }

    refute response.server_error?
    assert_equal "5553445555", Patient.last.phone
    assert count_before < Patient.all.count
  end

  test "Invalid CSV headers are validated" do
    invalid_file = fixture_file_upload(
      "../fixtures/files/invalid_patient_import.csv",
      "text/csv"
    )

    post :create, params: {
      organization_patient_import: {
        csv_file: invalid_file,
        organization_id: @organization.id
      },
      organization_id: @organization.friendly_id
    }

    assert_includes response.body, "CSV is not properly formatted"
  end

  test "Invalid file is validated" do
    image_file = fixture_file_upload(
      "../fixtures/files/casualdoctor.jpg",
      "image/jpg"
    )

    post :create, params: {
      organization_patient_import: {
        csv_file: image_file,
        organization_id: @organization.id
      },
      organization_id: @organization.friendly_id
    }

    assert_includes response.body, "is not a CSV"
  end

  test "Duplicates are not added to the database" do
    valid_file = fixture_file_upload(
      "../fixtures/files/valid_patient_import.csv",
      "text/csv"
    )

    post :create, params: {
      organization_patient_import: {
        csv_file: valid_file,
        organization_id: @organization.id
      },
      organization_id: @organization.friendly_id
    }

    refute response.server_error?
    assert_equal "5553445555", Patient.last.phone
    first_pass_count = Patient.all.count

    valid_file = fixture_file_upload(
      "../fixtures/files/valid_patient_import.csv",
      "text/csv"
    )

    post :create, params: {
      organization_patient_import: {
        csv_file: valid_file,
        organization_id: @organization.id
      },
      organization_id: @organization.friendly_id
    }

    assert_equal first_pass_count, Patient.all.count
  end
end
