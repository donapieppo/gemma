# frozen_string_literal: true

class Report::FormatComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(form)
    @f = form
  end
end
