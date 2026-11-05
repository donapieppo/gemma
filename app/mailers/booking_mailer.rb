class BookingMailer < ApplicationMailer
  def notify_booking(booking)
    @booking = booking
    @user = @booking.user
    @recipient = @booking.recipient
    @thing = @booking.thing
    @organization = @booking.organization
    mail(to: @organization.booking_mail.split(","), subject: "Avviso di nuova prenotazione materiale")
  end
end
