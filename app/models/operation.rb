# price_operations: [{:id=>198986, :n=>50, :p=>2000.0, :desc=>"ddt n. 158"}] 
# prezzo calcolato come 50 prezzo totale 20 euro dal carico 198986
class Operation < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, class_name: 'User'
  belongs_to :ddt
  belongs_to :thing
  belongs_to :organization
  has_many   :moves

  serialize  :price_operations, Array

  attribute :avoid_history_coherent, :boolean, default: false # quando creiamo a volte sappiamo che non serve perchè safe
  attribute :avoid_price_updating,   :boolean, default: false # se non viene modificato il prezzo o il numero di oggetti

  validates :date, :organization_id, :user_id, presence: true

  before_validation :fix_date 

  validate :validate_user,
           :validate_recipient,
           :check_organization,
           :validate_date,
           :validate_deposits

  after_save :update_moves
  after_save :rewrite_totals

  # per essere coerente con i costraint di mysql
  before_destroy :delete_moves
  after_destroy  :rewrite_totals
  after_destroy  :history_coherent?
                 
  # IMPORTANTISSIMO, 
  # la svolta per mettere date al posto di datetime e risolvere una tonnellata di problemi
  # ha solo il difetto che con stock e loads nella stessa giornata l'ordine non e' ottimale
  scope :ordered, -> { order('operations.date ASC, operations.number DESC') }
  scope :in_last_years, -> num { where('YEAR(date) >= ?', num) }

  def is_stock?    ; self.is_a?(Stock)    end
  def is_price?    ; self.is_a?(Price)    end
  def is_load?     ; self.is_a?(Load)     end
  def is_takeover? ; self.is_a?(Takeover) end
  def is_unload?   ; self.is_a?(Unload)   end 
  def is_booking?  ; self.is_a?(Booking)  end
  def is_shift?    ; self.is_a?(Shift)    end

  # in questo modo @_numbers diventa una cache (se è settato con numbers=)
  # undefined method `deposit_id' for {}:Hash

  def numbers
    @_numbers ||= self.moves.each_with_object({}) do |move, res| 
      res[move.deposit_id] = move.number
    end
  end

  # I form ci mandano i numbers = { depoit_id => number } con stringhe
  # settiamo anche il number totale dell'operazione 
  # {1=>4, 2=>6}
  def numbers=(nums)
    Rails.logger.debug("Operation numbers with #{nums.inspect}")
    
    # Rails6 From controller h is <ActionController::Parameters {"11459"=>"3"} permitted: true>
    nums = nums.to_hash if nums.is_a? ActionController::Parameters

    @_numbers = Hash.new
    if nums.is_a?(Hash)
      self.number = 0
      nums.each do |dep_id, num| 
        if num.to_i != 0
          @_numbers[dep_id.to_i] = num.to_i 
          self.number += num.to_i
        end
      end
    end
  end

  # recupera hash con { deposit_id => number }
  def numbers_hash
    self.moves.inject({}) {|n, m| n[m.deposit_id] = m.number; n}
  end

  def fix_date
    self.date ||= Date.today
  end

  def price_int
    self.price ? (self.price / 100).to_i : 0
  end

  def price_dec
    self.price ? (self.price % 100) : 0
  end

  def price_int=(p)
    self.price = p.to_i * 100 + self.price_dec
  end

  def price_dec=(p)
    self.price = self.price_int * 100 + p.to_i
  end

  # i dati come ddt (e relazione con la data) sono controllati dal validate dell'operation
  # rif cia e note non hanno problemi.
  #
  # Bisogna considerare come pericolosi i cambiamenti di data e di numero perche' possono
  # creare giacenze negative in uno scarico movimento di data successiva. Quindi si usa history_coherent?
  # Rails6 From controller h is <ActionController::Parameters {"11459"=>"3"} permitted: true>
  def aggiorna(h)
    avoid_history_coherent = avoid_price_updating = changed_numbers = false

    old_numbers = self.numbers
    if h[:numbers] && (h[:numbers] != old_numbers)
      self.numbers = h[:numbers]
      changed_numbers = true
    end
    h.delete(:numbers)

    # aggiorniamo con quello che è stato passato
    h.each do |k, v|
      self.send("#{k}=", v) 
    end

    avoid_price_updating   = true unless self.price_changed? || self.date_changed? || changed_numbers
    avoid_history_coherent = true unless self.date_changed? || changed_numbers # FIXME: 

    self.save
  end

  def recipient_upn
    self.recipient ? self.recipient.upn : ""
  end

  # possiamo passare 'pietro.donatini' 'pietro.donatini@unibo.it' 'Pietro donatini pietro.donatini@unibo.it'
  def recipient_upn=(upn)
    if upn =~ /(\w+\.\w+)/ 
      @_recipient_upn = "#{$1}@unibo.it"
    else
      @_recipient_upn = upn
    end
  end

  def price_string
    '%d,%02d€' % [self.price_int, self.price_dec]
  end

  def date_afternoon(date)
    # FIXME 
    # dovrebbe essere il controller, ma tant'e', con datepicker
    # cosi' il load sono in 00:00 e gli unload alle 12
    if date && (date.to_s =~ /00:00/ || date.to_s !~ /\d+:\d+/)
      date = date.to_s + ' 12:00' 
    end
    date 
  end

  protected 

  def validate_user
    begin
      User.find(self.user_id) 
    rescue => e
      self.errors.add(:user, e.to_s)
    end
  end

  def validate_recipient
    return true if @_recipient_upn.blank?
    Rails.logger.info("validating recipient_upn=#{@_recipient_upn}")
    begin
      u = User.find_or_syncronize(@_recipient_upn)
      self.recipient_id = u.id
    rescue => e
      Rails.logger.info "#{e.to_s} while validating recipient_upn=#{@_recipient_upn}"
      self.errors.add(:recipient_upn, e.to_s)
      self.errors.add(:base, e.to_s)
    end
  end

  def check_organization
    (self.thing.organization_id == self.organization_id) or raise DmUniboCommon::MismatchOrganization, "Materiale nella Struttura Sbagliata."
  end

  def validate_date
    errors.add(:date, "La data non può essere successiva a oggi.") if (self.date > Date.today) 
  end

  def recalculate_prices
    if self.organization.pricing
      if avoid_price_updating 
        Rails.logger.debug("SKIP update_next_prices") and return
      end
      self.thing.recalculate_prices
    end
  end

  # Depositi corretti, relativi allo stesso materiale 
  def validate_deposits
    # a volte non ci sono i numbers (tipo per aggiornamento di date)
    if @_numbers
      @_numbers.each_key do |dep_id|
        if (dep = Deposit.find_by_id(dep_id))
          if (dep.thing_id != self.thing_id) 
            errors.add(:base, 'Oggetti differenti in deposit and operation. Contattare amministratore.') and return 
          end
        else
          errors.add(:base, 'È necessario selezionare una provenienza corretta.') and return
        end
      end
    end
  end

  # @_numbers => {1 => 2, 3 => 4} nella forma deposit_id => number
  # settati con numbers=
  def update_moves
    Rails.logger.debug("Update_moves: self=#{self.inspect} e numbers=#{self.numbers.inspect}")

    @deposits_to_check ||= []

    tmp_numbers = @_numbers

    # aggiorno gli esistenti. move => deposit_id => number
    # I numbers sono la situazione attuale corretta. Non un'unione con i vecchi.
    # Quindi se in un vecchio location_id c'era un move e ora questo location_id non 
    # e' nei numbers, lo togliamo!!!!
    self.moves.each do |move|
      if tmp_numbers[move.deposit_id]
        if move.number != tmp_numbers[move.deposit_id] 
          move.update(number: tmp_numbers[move.deposit_id].to_i) or raise('NON SALVO MOVE IN update_moves')
          @deposits_to_check << move.deposit_id
        else
          # FIXME per ora mettiamo cosi' perche' non sappiamo se la data e' cambiata................. 
          # da sistemare ecchediavolo (usando changed?) http://api.rubyonrails.org/classes/ActiveRecord/Dirty.html
          @deposits_to_check << move.deposit_id
        end
      else
        move.destroy or raise('NON CANCELLO MOVE IN update_moves')
        @deposits_to_check << move.deposit_id
      end
      tmp_numbers.delete(move.deposit_id)
    end

    # aggiungiamo i nuovi
    tmp_numbers.each do |dep_id, num|
      if num.to_i != 0
        self.moves.create(deposit_id: dep_id,
                          number:     num)
        @deposits_to_check << dep_id
      end
    end

    history_coherent?
  end

  # FIXME VERIFICARE CHE FINZIONA CON after_destroy invece di before
  def delete_moves
    @deposits_to_check ||= []

    # la cancellazione di un unload / prenotazione non pone problemi
    self.instance_of?(Unload) and avoid_history_coherent = true
    self.instance_of?(Booking) and avoid_history_coherent = true

    self.moves.each do |m|
      @deposits_to_check << m.deposit_id 
      m.destroy or raise 'non cancello in delete_moves'
    end
    true
  end

  # vanno controllati tutti i deposit con moves sia presenti che cancellati (passati)
  def history_coherent?
    if avoid_history_coherent 
      Rails.logger.debug('SKIP history_coherent? and return true')
      return true
    end
    @deposits_to_check.each do |dep_id|
      sum = 0 
      Move.includes(:operation)
          .order('operations.date asc, operations.number desc, operations.id asc').references(:operations)
          .where('deposit_id = ?', dep_id).each do |m|
        sum += m.number
        Rails.logger.debug("history_coherent?: move = #{m.inspect} sum = #{sum}")
        (sum < 0) and raise Gemma::NegativeDeposit
      end
    end
    true
  end

  def rewrite_totals
    self.moves.each { |m| m.deposit.update_actual }
    self.thing.update_total
  end
end
