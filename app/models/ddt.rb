class Ddt < ApplicationRecord
  belongs_to :supplier
  belongs_to :organization
  has_many :loads
  has_many :operations

  @@types = {doctrasport: "ddt",
             fattura: "fatt",
             scontrino: "scontrino"}

  validates :gen, inclusion: {in: @@types.values, message: "È necessario scegliere il tipo di documento (ddt, fattura o scontrino)."}
  validates :name, presence: {message: "È necessario inserire nel dettaglio documento il numero di ddt o fattura."}
  validates :organization_id, presence: {message: "Manca Organization_id."}

  before_validation :fix_date

  before_create :set_new_number

  validate :validate_date,
    :no_other_in_year,
    :no_previous_loads,
    :myvalidate

  def short_description
    "#{self.gen} n.#{self.number}"
  end

  def short_description_with_date
    "#{self.gen} n.#{self.number} del #{self.date}"
  end

  # FIXME
  def description
    "#{self.name} (#{self.supplier})"
  end

  def long_description
    "#{self.gen} #{self.name} record n. #{self.number}"
  end

  def description_with_date
    "#{self.gen} #{self.name} del #{self.date.strftime('%d/%m/%Y')} di #{self.supplier} - record n. #{self.number}"
  end

  def to_s
    self.name
  end

  def self.possible_type_descripions
    @@types.values
  end

  protected

  # ddt si comporta come carichi e lo mettiamo a inizio giornata.
  def fix_date
    self.date ||= Date.today
    self.date = self.date.change(hour: 0, min: 0)
  end

  # non puo' essere dopo oggi alle 00:01
  def validate_date
    errors.add(:date, "La data non può essere successiva a oggi.") if self.date > Date.today
  end

  def no_other_in_year
    # simula validates_uniqueness_of ddt con scope organization_id, supplier_id ma basato sull'anno :-)
    other = Ddt.where(name: self.name)
               .where(supplier_id: self.supplier_id)
               .where(organization_id: self.organization_id)
               .where(['YEAR(date) = ?', self.date.year]).count

    if (other > 1) || (self.new_record? && other > 0)
      errors.add(:name, "Esiste un altro documento dello stesso fornitore con uguale numero e anno.")
    end
  end

  # Dobbiamo controllare che non esistano carichi associati con data precedente
  # nel caso di modifica (non new)
  def no_previous_loads
    if !self.new_record? && self.operations.where("date < ?", self.date).count > 0
      errors.add(:date, "Esistono carichi associati con data precedente a quella di questo documento.")
    end
  end

  # FIMXE: non controlliamo organization_id che viene settata nel controller
  # ma non esiste validates_existence_of ????
  # DB_FOREIGN_KEY
  def myvalidate
    Supplier.find(self.supplier_id)
  rescue ActiveRecord::RecordNotFound
    errors.add(:supplier_id, "Errore interno da segnalare. Non esiste supplier=#{self.supplier_id}")
    throw(:abort)
  end

  # FIXME: In fututo pensare a concurrecy...
  def set_new_number
    last = Ddt.where(organization_id: self.organization_id).order("number desc").first
    self.number = if last
      last.number.to_i + 1
    else
      self.number = 1
    end
  end
end
