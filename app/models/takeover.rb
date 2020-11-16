class Takeover < Operation
  belongs_to :thing
  belongs_to :organization
  has_many   :moves, foreign_key: "operation_id" 

  validate :validate_numbers 

  validates :recipient_id, presence: { message: "Utente non riconosciuto." }

  before_save :decide_for_history_coherent
  
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      attributes[:ddt_id] = nil
      attributes[:ycia] = nil
      attributes[:ncia] = nil
    end
    super(attributes)
  end

  # i carichi nuovi sono sempre safe 
  def decide_for_history_coherent
    avoid_history_coherent = self.new_record? 
  end

  # FIXME da fare dry con Unload
  def validate_numbers
    if (!self.numbers or self.numbers.size < 1)
      errors.add(:base, "È necessario indicare la quantità di oggetti e la loro provenienza")
      throw(:abort) 
    end
    
    self.numbers.each_value do |num|
      if (num < 1)
        errors.add(:base, "Il numero di oggetti da caricare deve essere positivo (ho #{num})")
        throw(:abort) 
      end
    end
  end
  

end

