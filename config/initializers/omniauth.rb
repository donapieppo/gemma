require "dm_unibo_common/omniauth/strategies/test"

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.path_prefix = "/dm_unibo_common/auth"
    # config.allowed_request_methods = [:get, :post]
  end

  if Rails.env.development?
    provider :developer, {
      fields: [:upn, :name, :surname],
      uid_field: :upn
    }
  end

  if Rails.env.test?
    provider :test
  end

  # provider :google_oauth2, ENV["GOT_GOOGLE_APP_ID"], ENV["GOT_GOOGLE_APP_SECRET"], {scope: "email"}
end
