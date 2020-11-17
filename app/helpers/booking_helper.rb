module BookingHelper
  def booking_title
    u = @user ? "di #{h @user}" : ""
    t = @thing? "per #{h @thing}" : ""

    "Prenotazioni <span class='font-weight-normal'>#{u} #{t}</span>".html_safe
  end

  def link_to_check url
    link_to dmicon('check'), url, data: {confirm: 'Siete sicuri di volere confermare la prenotazione?'}, title: 'Conferma la prenotazione.' 
  end

  def link_to_change_and_confirm url
    link_to dmicon('edit'), url, onclick:"return confirm('La prenotazione verrà cancellata e sarà possibile creare uno scarico con i suoi dati.');", title: "Modifica prima di confernare la prenotazione."
  end
end

