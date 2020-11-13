class ReportPolicy < ApplicationPolicy
  def index?
    current_organization_manager?
  end

  def form_articoli?
    index?
  end

  def articoli?
    index?
  end

  def form_giacenza?
    index?
  end

  def giacenza?
    index?
  end

  def form_sottoscorta?
    index?
  end

  def sottoscorta?
    index?
  end

  def form_storico?
    index?
  end

  def storico?
    index?
  end

  def form_scarichi?
    index?
  end

  def scarichi?
    index?
  end

  def form_receipts?
    index?
  end

  def receipts?
    index?
  end

  def form_ddts?
    index?
  end

  def ddts?
    index?
  end

  def ddt?
    index?
  end

  def receipt?
    current_organization_manager?
  end
end

