# frozen_string_literal: true

class Move::ActionsComponent < ViewComponent::Base
  def initialize(move)
    @move = move
    @operation = @move.operation
  end
end
