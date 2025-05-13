class Load < Operation
  belongs_to :ddt
  belongs_to :thing
  belongs_to :organization
  has_many :moves, foreign_key: :operation_id

  validate :validate_numbers,
    :validate_ddt,
    :validate_cia,
    :validate_price

  before_save :decide_for_history_coherent
  after_save :recalculate_prices
  after_destroy :recalculate_prices

  def initialize(attributes = {})
    avoid_history_coherent = false # aggiorniamo in aggiorna a false FIXME
    super(attributes)
  end

  private

  # FIXME da fare dry con Unload
  def validate_numbers
    if !self.numbers || self.numbers.empty?
      errors.add(:base, "È necessario indicare la quantità di oggetti e la loro provenienza.")
    else
      self.numbers.each_value do |num|
        if num < 1
          errors.add(:base, "Il numero di oggetti da caricare deve essere positivo (ho #{num})") and return false
        end
      end
    end
  end

  # i carichi nuovi sono sempre safe 
  def decide_for_history_coherent
    avoid_history_coherent = true if self.new_record?
  end

  # DDT
  def validate_ddt
    if (ddt = Ddt.find_by_id(self.ddt_id))
      (ddt.organization_id == self.organization_id) or raise DmUniboCommon::MismatchOrganization, 'MismatchOrganization in DDT.'

      errors.add(:date, 'La data del carico non può essere anteriore alla data del ddt.') if ddt.date > self.date 
      errors.add(:date, "La data del carico non può essere in anno differente dalla data del ddt. Consigliamo di scegliere come data l'ultimo giorno dell'anno del ddt.") if ddt.date.year != self.date.year
    else
      errors.add(:base, "Non c'è il ddt.")
    end
  end

  # CIA
  def validate_cia
    if self.ncia !~ /\w/
      self.ncia = nil
      self.ycia = nil
    elsif self.ycia.to_i > Date.today.year.to_i || self.ycia.to_i < 1996
      errors.add(:base, "Anno cia errato. Errore interno. Si prega di contattare l'amministratore.")
    end
  end

  # PRICE
  def validate_price
    if self.organization.pricing && self.price
      errors.add(:price, 'Il prezzo deve essere positivo.') if self.price < 0
    else
      self.price = nil
    end
  end
end
