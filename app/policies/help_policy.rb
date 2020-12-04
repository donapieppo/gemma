class HelpPolicy < ApplicationPolicy
  def index?
    true
  end

  def contacts?
    true
  end

  def old_url?
    true
  end
end

