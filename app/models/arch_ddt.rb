# Archivio, pochi controlli
class ArchDdt < ApplicationRecord
  belongs_to :supplier
  belongs_to :organization
  has_many :moves, class_name: "ArchOperation"

  @@types = {doctrasport: "ddt",
             fattura: "fatt",
             scontrino: "scontrino"}

  validates_inclusion_of :gen, in: @@types.values, message: "È necessario scegliere il tipo di documento (ddt o fattura)."

  def description
    return "Giacenza Iniziale" if ddt == "0"
    "#{ddt} (#{supplier})"
  end

  def description_with_date
    "#{gen} #{ddt} del #{date.strftime("%d/%m/%Y")} di #{supplier} - record n. #{number}"
  end
end
