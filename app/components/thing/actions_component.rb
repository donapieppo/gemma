class Thing::ActionsComponent < ViewComponent::Base
  include DmUniboCommon::IconHelper

  def initialize(current_user, thing)
    @current_user = current_user
    @thing = thing
    @policy = OrganizationPolicy.new(current_user, @thing.organization)
  end

  def render?
    @policy.manage?
  end

  def before_render
    @controller = controller.controller_name
    @action = controller.action_name
  end
end
