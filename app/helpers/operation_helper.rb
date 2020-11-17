module OperationHelper
  def recipient_hint(what)
    res = what.is_a?(Unload) ? "Riempire SOLO nel caso in cui il materiale venga consegnato ad un <strong>altro utente</strong> (non inserite voi stessi).<br/>" : ""
    res += "È possibile #{link_to dmicon('search') + "cercare l'utente", popup_find_user_path, remote: true} o scrivere l'indirizzo email "
    res += "o richiamare l'#{link_to 'ultimo utente inserito.', '#', id: 'last_recipient_link'}" if what.is_a?(Unload)
    res.html_safe
  end

  def organization_description(o)
    if o.is_load? 
      "carico da ".html_safe + link_to(o.ddt.long_description, ddt_path(o.ddt))
    elsif o.is_unload? or o.is_takeover? # booking < unload
      upn = (o.recipient || o.user).upn
      (o.recipient ? (upn + " <small class='text-muted'>(da #{o.user.cn})</small>").html_safe : h(upn)) +
      (o.is_booking? ? " <small>(prenotazione)</small>".html_safe : "")
    elsif o.is_stock? 
      "giacenza iniziale"
    elsif o.is_shift? 
      "<b>spostamento</b> <small>(registrato da #{o.user.upn})</small>".html_safe
    elsif o.is_price? 
      "&euro; cambio prezzo".html_safe
    end 
  end
end


