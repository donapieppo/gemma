# Archivio, pochi controlli se non year che e' quello che ci distingue dall'altro
class ArchOperation < ApplicationRecord
  belongs_to :thing, class_name: "ArchThing"
  belongs_to :ddt, class_name: "ArchDdt", optional: true

  # il nome in dsa (nome e cognome per inviare mail)
  attr_reader :recipient_name

  def is_stock?
    is_a?(ArchStock)
  end

  def is_load?
    is_a?(ArchLoad)
  end

  def is_unload?
    is_a?(ArchUnload)
  end

  def self.years(organization)
    where(organization_id: organization.id)
      .select("YEAR(date) as year")
      .group("YEAR(date)").map { |o| o.year.to_i }
  end
end
