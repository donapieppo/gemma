class Thing::ActionsComponent < ViewComponent::Base
  def initialize(current_user, thing)
    @current_user = current_user
    @thing = thing
  end

  def before_render
    @controller = controller.controller_name 
    @action = controller.action_name
  end
end
