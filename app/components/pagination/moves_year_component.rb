class Pagination::MovesYearComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(first_year, last_year, display_year, thing, deposit)
    @first_year = first_year
    @last_year = last_year
    @display_year = display_year
    @thing = thing
    @deposit = deposit
  end

  def render?
    @first_year != @last_year
  end
end
