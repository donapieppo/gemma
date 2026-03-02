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

    # Per azoto: serialize :containers, coder: YAML
    # nel caso di container caldo l'azoto usato e' x * config.containers_with_multipliers[x]
    config.dewar_liters_and_hot_liters = {
      3 => 10,
      4 => 12,
      5 => 13,
      10 => 20,
      20 => 33,
      25 => 39,
      30 => 46,
      35 => 52,
      40 => 59,
      50 => 72,
      60 => 85,
      80 => 111,
      100 => 137,
      120 => 163
    }
    config.possible_dewars = config.dewar_liters_and_hot_liters.keys
  end
end
