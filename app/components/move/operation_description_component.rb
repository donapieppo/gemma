# frozen_string_literal: true

class Move::OperationDescriptionComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(operation)
    @operation = operation
  end
end
