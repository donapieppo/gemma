class Unload < Operation
  belongs_to :thing
  belongs_to :organization
  has_many   :moves, foreign_key: :operation_id # in realta' has one diverso da load

  validate   :validate_numbers
  after_save :recalculate_prices

  # un solo deposito
  def deposit_id
    nil
  end

  # in rails 3.1 initialize ha 2 arg.
  # pensare a after_initialize
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      attributes[:ddt_id] = nil 
      attributes[:date] = date_afternoon(attributes[:date]) if attributes[:date]
    end
    super(attributes)
  end

  def date_afternoon(date)
    # FIXME 
    # dovrebbe essere il controller, ma tant'e', con datepicker
    # cosi' il load sono in 00:00 e gli unload alle 12
    if date and (date.to_s =~ /00:00/ or date.to_s !~ /\d+:\d+/)
      date = date.to_s + ' 12:00' 
    end
    date 
  end

  # FIXME da fare dry con Load
  def validate_numbers
    if (!self.numbers or self.numbers.size < 1)
      errors.add(:number, "È necessario indicare la quantità di oggetti.")
      throw(:abort) 
    end

    self.numbers.each_value do |num|
      if (num >= 0)
        errors.add(:number, "Il numero di oggetti da scaricare deve essere positivo.")
        throw(:abort) 
      end
    end
  end

  # Noi si puo' solo cancellare o abbassare il numero quindi non pericolosa 
  # Aggiorniamo noi (operation e il singolo movimento associato)
  def modify_number(num)
    (num < 0) or return false

    # abbiamo di certo un solo move associato essendo noi uno scarico
    single_move = self.moves.first

    # sara' sempre vero (possiamo solo calare i numeri legati agli scarichi)
    (num > single_move.number) and avoid_history_coherent = true

    self.numbers = { single_move.deposit_id => num } 

    self.save
  end
end


