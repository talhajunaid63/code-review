class StripeEvents::PaymentSucceededService
  def call(event)
    stripe_subscription_id = event.data.object.subscription rescue nil
    return unless stripe_subscription_id

    stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id) rescue nil
    local_subscription = Organization::Subscription.find_by_stripe_id(stripe_subscription_id)
    if stripe_subscription && local_subscription
      local_subscription.current_period_end = Time.at(stripe_subscription.current_period_end)
      local_subscription.save
    end
  end
end
