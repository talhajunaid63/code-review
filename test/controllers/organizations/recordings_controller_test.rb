require "test_helper"
feature "OrganizationsRecordingsControllerTest" do
  include AuthenticationHelper
  include TextMessageHelper

  setup do
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @recording = visit_recordings(:visit_recording_1)
    stubs_text_message_send_text
  end

  scenario "Index" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_recordings_path(@organization)
    expect(page).must_have_content("Recording History")
    expect(page).must_have_content("5 minutes")
  end

  scenario "Show" do
    authenticate_user(@org_admin, @org_admin.phone)
    visit organization_recording_path(@organization, @recording)
    expect(page).must_have_content("Visit Recording")
    expect(page).must_have_content("Download")
  end
end
