# config/initializers/mailgun.rb
require "mailgun_rails"

Mailgun.configure do |config|
  config.api_key = ENV.fetch("MAILGUN_API_KEY")
  config.domain  = ENV.fetch("MAILGUN_DOMAIN")
end
