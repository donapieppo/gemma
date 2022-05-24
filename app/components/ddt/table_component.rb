class Ddt::TableComponent < ViewComponent::Base
  def initialize(ddts, current_user)
    @ddts = ddts
    @current_user = current_user
  end
end

