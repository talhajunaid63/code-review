Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_connect,
    ApplicationConfig['STRIPE_CONNECT_CLIENT_ID'],
    ApplicationConfig['STRIPE_API_KEY'],
    scope: 'read_write',
    callback_path: '/users/auth/stripe_connect/callback'
end
