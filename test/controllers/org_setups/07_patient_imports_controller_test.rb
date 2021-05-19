require "test_helper"
feature "OrgSetupsPatientImportsControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper

  setup do
    StripeMock.start
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 9)
    UserImport.delete_all
    stub_s3_upload
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  def stub_s3_upload
    s3_obj = stub("Aws::S3::Object stub", key: "s3-file-key")
    s3_client = stub("S3Client stub", upload: s3_obj, download: file_fixture("valid_patient_import.csv").to_s)
    S3Client.stubs(:new).returns(s3_client)
  end

  scenario "user can skip patient import" do
    click_link "Skip for now"
    expect(page).must_have_content "Confirm Subscription"
  end

  scenario "user can import patients" do
    find('#organization_patient_import_csv_file', visible: false).set(file_fixture("valid_patient_import.csv"))
    click_button "Import Patients/Clients"
    expect(page).must_have_content "Patients/Clients import is in progress"
  end
end
