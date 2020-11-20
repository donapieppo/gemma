# Archivio, pochi controlli se non year che e' quello che ci distingue dall'altro
class ArchOperation < ApplicationRecord
  belongs_to :thing, class_name: 'ArchThing'
  belongs_to :ddt,   class_name: 'ArchDdt', optional: true

  # il nome in dsa (nome e cognome per inviare mail)
  attr_reader :recipient_name

  def is_stock?
    self.is_a?(ArchStock)
  end

  def is_load?
    self.is_a?(ArchLoad)
  end

  def is_unload?
    self.is_a?(ArchUnload)
  end

  def self.years(organization)
    self.where(organization_id: organization.id)
        .select('YEAR(date) as year')
        .group('YEAR(date)').map { |o| o.year.to_i }
  end
end


