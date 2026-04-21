require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gemma
  class Application < Rails::Application
    config.load_defaults 8.1
    config.unibo_common = config_for(:unibo_common)

    config.hosts << config.unibo_common.host

    config.time_zone = "Rome"
    config.i18n.default_locale = :it

    config.authlevels = {
      read: 10,
      book: 15,
      unload: 20,
      give: 30,
      manage: 40,
      edit: 50
    }

    config.active_record.yaml_column_permitted_classes = [Symbol]

    # better for docker demo :-)
    config.require_master_key = false

    Rails.application.routes.default_url_options = {
      host: config.unibo_common.host,
      protocol: "https"
    }
  end
end
