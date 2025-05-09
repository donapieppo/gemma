# il livello e' solo un numero definito da costanti
#
# TO_READ:   può solo leggere le gicenze
# TO_ORDER:  può ordinare l'acquisto di materiale
# TO_BOOK:   può prenotare
# TO_UNLOAD: può scaricare
# TO_GIVE:   può scaricare a nome di altri
# TO_MANAGE: può amministrare la struttura
# TO_EDIT:   può editare la struttura (direttore amministrativo). Aggiungendo utenti.
# TO_CESIA:  amministratore del programma (super admin)
#
# il tipo di autorizzazione dipende dall'ip del client e dal login name (upn)

class Authorization
  include DmUniboCommon::Authorization

  configure_authlevels
end
