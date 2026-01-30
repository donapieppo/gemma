# frozen_string_literal: true

class Ddt::TableComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(ddts, current_user)
    @ddts = ddts
    @current_user = current_user
  end
end
