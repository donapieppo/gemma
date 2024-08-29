require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gemma
  class Application < Rails::Application
    config.load_defaults 7.1

    config.hosts << "gemma.unibo.it"

    config.autoload_paths << "#{Rails.root}/app/pdfs"
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

    config.lograge.enabled = true

    config.dm_unibo_common = ActiveSupport::HashWithIndifferentAccess.new config_for(:dm_unibo_common)
    config.active_record.yaml_column_permitted_classes = [Symbol]
  end
end
