# frozen_string_literal: true

class Move::ActionsComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(move)
    @move = move
    @operation = @move.operation
  end
end
