# frozen_string_literal: true

class Booking::LineComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper
  include BookingHelper

  def initialize(booking)
    @booking = booking
    @to_user = (@booking.recipient || @booking.user)
  end
end
