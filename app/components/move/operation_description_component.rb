# frozen_string_literal: true

class Move::OperationDescriptionComponent < ViewComponent::Base
  def initialize(operation)
    @operation = operation
  end
end
