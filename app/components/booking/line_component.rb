# frozen_string_literal: true

class Booking::LineComponent < ViewComponent::Base
  def initialize(booking)
    @booking = booking
    @to_user = (@booking.recipient or @booking.user)
  end
end
