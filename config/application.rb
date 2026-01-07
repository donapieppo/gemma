require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gemma
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_paths << "#{Rails.root}/app/pdfs"
    config.time_zone = "Rome"
    config.i18n.default_locale = :it

    config.hosts += ENV.fetch("ALLOWED_HOSTS", "").split(",")
    # config.host_authorization = {
    #   exclude: ->(request) { request.path == "/up" }
    # }

    config.authlevels = {
      read: 10,
      book: 15,
      unload: 20,
      give: 30,
      manage: 40,
      edit: 50
    }

    config.unibo_common = config_for(:unibo_common)
    config.active_record.yaml_column_permitted_classes = [Symbol]

    # better for docker demo :-)
    config.require_master_key = false
  end
end
