# upn di amministratori del programma (Array di upn)
CESIA_UPN = ["pietro.donatini@unibo.it"]

FIRST_LOCATION = "generale"
FIRST_GROUP = "cancelleria"

CREDENZIALI_ERRATE_STRING = "Credenziali errate"

GEMMA_TEST_NOW = Date.parse("2017-01-07")
IVAS = [4, 5, 10, 22]

module Gemma
  class Application < Rails::Application
    config.session_store :cookie_store, key: "_gemma25"

    config.active_record.belongs_to_required_by_default = false
  end
end
