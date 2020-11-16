class Shift < Operation
  belongs_to :thing
  belongs_to :organization
  has_many   :moves, foreign_key: :operation_id

  validate :different_deposits,
           :same_numbers

  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      number = attributes[:number] ? attributes.delete(:number).to_i : 0
      if attributes[:from] and attributes[:to]
        attributes[:numbers] = { attributes.delete(:from).to_i => number * -1, attributes.delete(:to) => number }
      else
        attributes.delete(:from)
        attributes.delete(:to)
      end
    end
    super(attributes)
  end

  # REFACTOR
  def from
    Deposit.find(self.numbers_hash.select {|k,v| v < 0}.flatten.first)
  end

  # REFACTOR
  def to
    Deposit.find(self.numbers_hash.select {|k,v| v > 0}.flatten.first)
  end

  private

  def different_deposits
    if self.numbers and self.numbers.size != 2
      Rails.logger.info("Refuse shift on same deposit.")
      errors.add(:base, "È necessario che le ubicazioni di partenza e arrivo siano diverse.")
    end
  end

  def same_numbers
    if self.numbers.each_value.sum != 0
      errors.add(:base, "È necessario che i numeri siano coerenti. Errore interno all'applicazione.")
    end
  end
end


