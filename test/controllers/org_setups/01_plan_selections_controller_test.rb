require "test_helper"
feature "OrgSetupsPlanSelectionsControllerTest" do
  include OrgSetupHelper
  include PaymentHelper
  include TextMessageHelper

  setup do
    StripeMock.start
    @phone = "555-099-5555"
    stubs_text_message_send_text
    org_onboarding_setup(@phone, 3)

    @professional_plan = organization_plans(:professional_plan)

    # Setting up professional plan with Stripe
    @stripe_professional_plan = stripe_helper.create_plan(:id => 'professional', :amount => 290000, interval: "month")
    @professional_plan.stripe_id = @stripe_professional_plan.id
    @professional_plan.save
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "user can choose a plan" do
    expect(page).must_have_content "Select Your Plan"

    first("#select-subscription-#{@professional_plan.id}").click

    expect(page).must_have_content "Basic Details"
    org_setup = OrgSetup.last
    assert_equal @professional_plan.id, org_setup.plan_id
  end

end
