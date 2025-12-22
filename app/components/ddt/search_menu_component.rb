class Ddt::SearchMenuComponent < ViewComponent::Base
  include DmUniboCommon::ApplicationHelper

  def initialize(organization)
    @organization = organization
    oggi = Date.today.year.to_i
    @years_cia = [oggi, oggi - 1, oggi - 2]
  end
end
