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
      4 => 11,
      5 => 13,
      10 => 19,
      20 => 32,
      25 => 39,
      30 => 45,
      35 => 52,
      40 => 58,
      50 => 71,
      60 => 84,
      80 => 110,
      100 => 136,
      120 => 162
    }
    config.possible_dewars = config.dewar_liters_and_hot_liters.keys
  end
end
