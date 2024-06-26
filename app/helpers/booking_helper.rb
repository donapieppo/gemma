module BookingHelper
  def booking_title
    u = @user ? "di #{h @user} <small>(#{h @user.upn})</small>" : ""
    t = @thing ? "per #{h @thing}" : ""

    "<h1>Prenotazioni<br/><small>#{u} #{t}</small></h1>".html_safe
  end

  def link_to_check url
    button_to url, form: {
      data: {"turbo-confirm": "Siete sicuri di voler confermare la prenotazione?"},
      class: "d-inline px-0 mx-0"
    }, title: "Conferma la prenotazione.", class: "px-0 mx-0" do
      dm_icon "circle-check", "regular", size: :lg
    end
  end

  def link_to_change_and_confirm url
    link_to dm_icon("edit"),
      url,
      onclick: "return confirm('La prenotazione verrà cancellata e sarà possibile creare uno scarico con i suoi dati.');",
      title: "Modifica prima di confernare la prenotazione."
  end
end
