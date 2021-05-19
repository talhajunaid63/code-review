require "test_helper"

feature "StripeEventsSubscriptionsTest" do
  include PaymentHelper
  include StripeHelper

  setup do
    StripeMock.start
    Organization::Subscription.delete_all
    @org_admin = org_admins(:org_admin_michael)
    @organization = organizations(:rmg)
    @professional_plan = organization_plans(:professional_plan)
  end

  def teardown
    StripeMock.stop
    Capybara.current_session.reset!
  end

  scenario "invoice.payment_succeeded updates subscription current_period_end attribute" do
    StripeMock.start
      @organization = create_customer(@organization)
      @professional_plan = create_plan(@professional_plan)
      stripe_subscription = create_subscription(@professional_plan, @organization)

      subscription = @organization.subscriptions.create(
        plan: @connect_plan, stripe_id: stripe_subscription.id, current_period_end: Time.now - 2.days
      )

      payload = File.read("test/fixtures/stripe_webhooks/invoice.payment_succeeded.json")
      event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
      event.data.object.subscription = stripe_subscription.id

      StripeEvents::PaymentSucceededService.new.call(event)
    StripeMock.stop

    subscription.reload
    assert_equal stripe_subscription.current_period_end, subscription.current_period_end.to_i
  end
end
