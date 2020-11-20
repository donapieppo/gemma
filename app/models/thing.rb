# future_prices: [{:id=>284734, :n=>4, :p=>1000.0}] 4 pezzi a 10 euro l'uno dal carico 284734
class Thing < ApplicationRecord
  belongs_to :group
  belongs_to :organization
  has_many   :operations
  has_many   :moves, through: :operations # FIXME
  has_many   :loads
  has_many   :unloads
  has_many   :shifts
  has_many   :takeovers
  has_many   :stocks
  has_many   :deposits,  dependent: :destroy
  has_many   :locations, through:   :deposits
  has_many   :bookings,  dependent: :destroy
  has_many   :barcodes,  dependent: :destroy
  has_many   :images,    dependent: :destroy

  serialize  :future_prices, Array

  before_validation :strip_name_blanks

  validates :organization_id, :group_id, presence: true
  validates :name, uniqueness: { scope: [:organization_id], message: "L'articolo esiste già.", case_sensitive: false },
                   presence: true
  validates :minimum, numericality: { greater_than_or_equal_to: 0 } 

  validate  :check_group_organization  

  before_destroy :check_no_associated_moves, prepend: true

  def create_deposits(location_ids)
    location_ids = location_ids.select { |i| i.to_i > 0 }
    Location.find(location_ids).each do |loc|
      (loc.organization_id == self.organization_id) or raise DmUniboCommon::MismatchOrganization, 'Struttura non permessa.'
      loc.deposits.create(thing_id:        self.id, 
                          organization_id: self.organization_id,
                          actual:          0) or return false
    end
  end

  def has_operation?
    self.operations.any?
  end

  def short_name
    self.name[0..80]
  end

  def max_actual_in_deposits
    self.deposits.map(&:actual).max
  end

  def update_total
    # Piu' veloce con deposits ma per ora va bene cosi'
    # sum = self.deposits.sum(:actual)
    sum = self.operations.sum(:number)
    ( sum < 0 ) and raise Gemma::NegativeDeposit
    self.update_attribute(:total, sum)
  end

  def to_s
    self.name
  end

  def to_s_with_description
    d = self.description.blank? ? '' : " (#{self.description})"
    self.name + d
  end

  def self.inactive(organization)
    active_ids = organization.operations.select(:thing_id).uniq.map(&:thing_id)
    organization.things.where.not(id: active_ids)
  end

  def recalculate_prices
    pc = PriceCalculator.new
    self.operations.ordered.each do |o|
      price = 0
      price_operations = []

      if o.number > 0
        pc.add(o)
      elsif o.number < 0
        number = -1 * o.number
        while number > 0
          (stack_operation, n, p) = pc.get(number)

          stack_price = n*p

          if stack_price > 0
            if stack_operation.is_a?(Load)
              ddt = stack_operation.ddt
              price_operations << { id: stack_operation.id, n: n, p: stack_price, desc: "#{ddt.gen} n. #{ddt.number}" }
            elsif stack_operation.is_a?(Takeover)
              price_operations << { id: stack_operation.id, n: n, p: stack_price, desc: "reso da #{stack_operation.recipient.upn}" }
            elsif stack_operation.is_a?(Stock)
              price_operations << { id: stack_operation.id, n: n, p: stack_price, desc: 'giacenza iniziale' }
            end
          end

          price += stack_price
          number -= n
        end
        o.update_columns(price: price, price_operations: price_operations)
      end
    end
    self.update_columns(future_prices: pc.remaining_stack)
  end

  def generate_barcode
    str = "g-#{self.id}"
    self.barcodes.create(organization_id: self.organization_id, name: str)
  end

  protected

  def strip_name_blanks
    self.name = self.name.squish
  end

  def check_group_organization
    (self.group.organization_id == self.organization_id) or raise DmUniboCommon::MismatchOrganization, 'Struttura non permessa.'
  end

  def check_no_associated_moves
    # FIXME: BUG risultano certe operations senza moves... da riflettere e sistemare
    if self.moves.any? || self.operations.any?
      errors[:base] << 'Ci sono carichi e scarichi associati a questo articolo che devono prima essere cancellati.'
      throw :abort
    end
  end
end
