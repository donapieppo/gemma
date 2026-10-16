# frozen_string_literal: true

class Report::FormComponent < ViewComponent::Base
  def initialize(title: title)
    @title = title
  end
end
