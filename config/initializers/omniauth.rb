require "dm_unibo_common/omniauth/strategies/test"

OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.path_prefix = "/dm_unibo_common/auth"
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
end
