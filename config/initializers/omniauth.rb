# config/initializers/omniauth.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV.fetch('GOOGLE_CLIENT_ID'),
    ENV.fetch('GOOGLE_CLIENT_SECRET'),
    {
      hd:    'tadl.org',
      scope: 'email,profile',
      prompt: 'select_account'
    }
end

# Protect from CSRF attacks in OmniAuth callbacks
OmniAuth.config.allowed_request_methods = [:post, :get]
