Stripe.api_key = ApplicationConfig['STRIPE_API_KEY']

StripeEvent.signing_secrets = [
  ApplicationConfig['STRIPE_SIGNING_SECRET_PAYMENT_SUCCEEDED'],
  ApplicationConfig['STRIPE_SIGNING_SECRET_ACCOUNT_DEAUTHORIZED']
]

StripeEvent.configure do |events|

  events.subscribe 'invoice.payment_succeeded', StripeEvents::PaymentSucceededService.new
  events.subscribe 'account.application.deauthorized', StripeEvents::AccountDeauthorizedService.new

  events.all StripeEvents::EventLoggerService.new(Rails.logger)
end
