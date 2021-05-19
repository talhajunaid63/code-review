require "test_helper"

feature "FreeSubscriptionsTest" do
  include AuthenticationHelper
  include PaymentHelper
  include SubscriptionsHelper
  include TextMessageHelper

  setup do
    Organization::Subscription.delete_all
    StripeMock.start
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @individual_plan = organization_plans(:individual_plan)
    stubs_text_message_send_text
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "It is possible to subscribe to a free/individual plan without a payment method" do
    assert_equal 0, @organization.subscriptions.count
    authenticate_user(@org_admin, @org_admin.phone)

    subscribe_to(@individual_plan)
    expect(page).must_have_content("Subscription Successful")

    # The subscription is successfuly stored locally
    assert_equal 1, @organization.subscriptions.count
    subscription = @organization.subscriptions.first
    assert !subscription.stripe_id.present?
    assert_equal "individual", subscription.plan.name

    # Nothing is stored in Stripe
    assert_equal 0, Stripe::Subscription.list.count
  end

end
