require "test_helper"

feature "PaidSubscriptionsTest" do
  include AuthenticationHelper
  include PaymentHelper
  include SubscriptionsHelper
  include TextMessageHelper
  include StripeHelper

  setup do
    StripeMock.start
    Organization::Subscription.delete_all
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @professional_plan = organization_plans(:professional_plan)
    @practice_plan = organization_plans(:practice_plan)
    @individual_plan = organization_plans(:individual_plan)
    stubs_text_message_send_text
    @recording_plan = organization_plans(:recording_plan)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "Organization admins can view and select an organizations membership/subscription" do
    assert_equal 0, @organization.subscriptions.count
    authenticate_user(@org_admin, @org_admin.phone)

    StripeMock.start
      @organization = create_customer(@organization)
      @professional_plan = create_plan(@professional_plan)
      create_plan(@recording_plan)
      subscribe_to(@professional_plan)
      stripe_total_subscriptions = Stripe::Subscription.list.count
      subscription = @organization.subscriptions.first
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
    StripeMock.stop

    expect(page).must_have_content("Subscription Successful")

    assert_equal 1, @organization.subscriptions.count
    assert subscription.stripe_id.present?
    assert subscription.stripe_subscription_item_id.present?

    assert_equal 1, stripe_total_subscriptions
    assert_equal @organization.stripe_id, stripe_subscription.customer
    assert_equal "professional", stripe_subscription.items.first.plan.id
  end

  scenario "Organization admins can update an organization's subscription" do
    assert_equal 0, @organization.subscriptions.count
    authenticate_user(@org_admin, @org_admin.phone)

    StripeMock.start
      @organization = create_customer(@organization)
      @professional_plan = create_plan(@professional_plan)
      create_plan(@recording_plan)
      subscribe_to(@professional_plan)
      subscription = @organization.subscriptions.first
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)

      assert_equal "professional", stripe_subscription.items.first.plan.id

      @practice_plan = create_plan(@practice_plan)
      subscribe_to(@practice_plan)
      subscription = @organization.subscriptions.first
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
    StripeMock.stop

    assert_equal "practice", stripe_subscription.plan.id
  end

  scenario "Updating to free plan subscription cancels stripe subscription" do
    assert_equal 0, @organization.subscriptions.count
    authenticate_user(@org_admin, @org_admin.phone)
    # organization_add_payment(@organization)

    StripeMock.start
      @organization = create_customer(@organization)
      @professional_plan = create_plan(@professional_plan)
      create_plan(@recording_plan)
      subscribe_to(@professional_plan)
      subscription = @organization.subscriptions.first
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)

      assert_equal "professional", stripe_subscription.items.first.plan.id
      subscribe_to(@individual_plan)

      stripe_subscription = Stripe::Subscription.list.first
    StripeMock.stop

    subscription = @organization.subscriptions.first
    assert_equal "individual", subscription.plan.name
    assert !subscription.plan.stripe_id

    assert_equal @organization.stripe_id, stripe_subscription.customer
    assert_equal "professional", stripe_subscription.items.first.plan.id
    assert_equal "canceled", stripe_subscription.status
  end

  scenario "Only Organizations with a payment method can subscribe" do
    assert_equal 0, @organization.subscriptions.count
    authenticate_user(@org_admin, @org_admin.phone)

    visit organization_subscriptions_path(@organization)
    expect(page).must_have_content("Subscriptions")
    expect(page).must_have_content("Web based platform")
    first("#select-subscription-#{@professional_plan.id}").click

    expect(page).must_have_content("Update Payment Method")
  end
end
