# Archivio, pochi controlli 
class ArchDdt < ApplicationRecord
  belongs_to :supplier
  belongs_to :organization
  has_many   :moves, class_name: 'ArchOperation'

  @@types = { doctrasport: "ddt",
              fattura:     "fatt",
              scontrino:   "scontrino"}

  validates_inclusion_of :gen, in: @@types.values, message: "È necessario scegliere il tipo di documento (ddt o fattura)."

  def description
    return "Giacenza Iniziale" if self.ddt == "0"
    "#{self.ddt} (#{self.supplier})"
  end

  def description_with_date
    "#{self.gen} #{self.ddt} del #{self.date.strftime("%d/%m/%Y")} di #{self.supplier} - record n. #{self.number}"
  end

end


