# GIACENZA INIZIALE
class Stock < Operation
  belongs_to :thing
  belongs_to :organization
  has_many   :moves, foreign_key: :operation_id

  validate :no_previous_stock

  after_save    :recalculate_prices
  after_destroy :recalculate_prices

  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      attributes[:ddt_id] = nil
      attributes[:ycia]   = nil
      attributes[:ncia]   = nil
    end
    super(attributes)
  end

  # verifico che non ci siano precedenti giacenze iniziali per lo stesso oggetto
  def no_previous_stock
    if (m = Stock.where(thing_id: self.thing_id).first)
      # se non sono nuovo o se sono nuovo e non solo l'unico
      if self.new_record? || m.id != self.id
        errors.add(:base, 'Esiste già una giacenza iniziale per questo materiale.')
        throw(:abort) 
      end
    end
    true
  end
end
