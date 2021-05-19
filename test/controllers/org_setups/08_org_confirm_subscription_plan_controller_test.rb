require "test_helper"
feature "OrgSetupsOrgSubscriptionPlansControllerTest" do
  include OrgSetupHelper
  include TextMessageHelper
  include StripeHelper

  setup do
    StripeMock.start
    Organization::Subscription.delete_all
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 10)
    @recording_plan = organization_plans(:recording_plan)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "can confirm subscription plan" do
    StripeMock.start
      expect(page).must_have_content "Confirm Subscription"
      create_customer(@organization)
      @professional_plan = create_plan(@professional_plan)
      recording_plan = create_plan(@recording_plan)

      click_button "Confirm Subscription"
    StripeMock.stop

    expect(page).must_have_content "Organization Settings"
    expect(page).must_have_content "Need Help?"
  end
end
