# frozen_string_literal: true

class Booking::LineComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(booking)
    @booking = booking
    @to_user = (@booking.recipient or @booking.user)
  end
end
