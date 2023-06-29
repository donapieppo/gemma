# frozen_string_literal: true

class Move::LineComponent < ViewComponent::Base
  def initialize(move, number, total, pricing)
    @move = move
    @operation = @move.operation
    @number = number
    @total = total
    @pricing = pricing
  end
end
