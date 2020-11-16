# Quanto della struttura e' configurabile dal suo
# amministratore
class Configuration

  # default di ogni quanto notificare gli scarichi
  # n = mai (di default)
  # y = ad ogni scarico
  # dwm = giornalmente, settimanalmente, mensilmente
  NOTIFY_FREQUENCIES = [ 'n', 'y', 'd', 'w', 'm' ]

  NO_MAIL      = 'n'
  YES_MAIL     = 'y'
  DAILY_MAIL   = 'd'
  WEEKLY_MAIL  = 'w'
  MONTHLY_MAIL = 'm'

  SELECT_COLLECTION = [["disabilita l'invio delle mail per gli scarichi", NO_MAIL],
                       ["abilita invio della email per ogni scarico", YES_MAIL], 
                       ["abilita invio giornaliero delle mail di riepilogo degli scarichi", DAILY_MAIL],
                       ["abilita invio settimanale delle mail di riepilogo degli scarichi", WEEKLY_MAIL], 
                       ["abilita invio mensile delle mail di riepilogo degli scarichi", MONTHLY_MAIL]]

end

