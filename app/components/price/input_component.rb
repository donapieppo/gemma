# frozen_string_literal: true

class Price::InputComponent < ViewComponent::Base
  def initialize(form, current_organization)
    @form = form
    @current_organization = current_organization
  end

  private

  def render?
    @current_organization.pricing
  end
end
