# upn di amministratori del programma (Array di upn)
CESIA_UPN = ['pietro.donatini@unibo.it']

FIRST_LOCATION = 'generale'
FIRST_GROUP    = 'cancelleria'
    
CREDENZIALI_ERRATE_STRING = "Credenziali errate"

GEMMA_TEST_NOW = Date.parse("2017-01-07")
IVA = 1.22

module Gemma
  class Application < Rails::Application
    config.domain_name = 'unibo.it'

    config.html_title = "GE.M.MA - GEstione Multiutente MAteriale di consumo"
    config.html_description = "Gestione Multiutente MAteriale di consumo. Università di Bologna."
    config.header_title    = 'Ge.M.Ma'
    config.header_subtitle = 'Gestione Multiutente MAteriale di consumo'
    config.header_icon     = 'shopping-cart' 
    config.contact_mail    = 'dipmat-gemma@unibo.it'

    config.default_from    = 'Ge.M.Ma <notifica.inviodlist.08218@unibo.it>'
    config.reply_to        = 'dipmat-supportoweb@unibo.it'

    config.dm_unibo_common.update(
      login_method:        :log_and_create,
      message_footer:      %Q{},
      impersonate_admins:  ['pietro.donatini@unibo.it', 'valeria.montesi3@unibo.it', 'valeria.montesi4@unibo.it'],
      interceptor_mails:   ['donatini@dm.unibo.it'],
      main_impersonations: ['giovanni.dore@unibo.it', 'pietro.donatini@unibo.it', 'bruno.franchi@unibo.it', 'sandra.scagliarini@unibo.it', 'fiammetta.ferroni@unibo.it','santa.santoianni@unibo.it', 'oscar.losurdo@unibo.it'] 
    )
    config.active_record.belongs_to_required_by_default = false
  end
end
