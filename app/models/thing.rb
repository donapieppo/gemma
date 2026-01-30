# future_prices: [{:id=>284734, :n=>4, :p=>1000.0}] 4 pezzi a 10 euro l'uno dal carico 284734
class Thing < ApplicationRecord
  belongs_to :group
  belongs_to :organization
  has_many :operations
  has_many :moves, through: :operations # FIXME
  has_many :loads
  has_many :unloads
  has_many :shifts
  has_many :takeovers
  has_many :stocks
  has_many :deposits, dependent: :destroy
  has_many :locations, through: :deposits
  has_many :bookings, dependent: :destroy
  has_many :barcodes, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :future_prices, coder: YAML, type: Array
  serialize :dewars, coder: YAML

  before_validation :strip_name_blanks
  before_validation :convert_dewars_to_integers

  validates :organization_id, :group_id, presence: true
  validates :name, uniqueness: {scope: [:organization_id], message: "L'articolo esiste già.", case_sensitive: false},
                   presence: true # standard:disable all
  validates :minimum, numericality: {greater_than_or_equal_to: 0}

  validate :check_group_organization

  before_destroy :check_no_associated_moves, prepend: true

  def create_deposits(location_ids)
    location_ids = location_ids.select { |i| i.to_i > 0 }
    Location.find(location_ids).each do |loc|
      (loc.organization_id == organization_id) or raise DmUniboCommon::MismatchOrganization, "Struttura non permessa."
      loc.deposits.create(thing_id: id,
                          organization_id: self.organization_id, # standard:disable all
                          actual: 0) or return false # standard:disable all
    end
  end

  def has_operation?
    operations.any?
  end

  def short_name
    name[0..80]
  end

  def max_actual_in_deposits
    deposits.map(&:actual).max
  end

  def update_total
    # Piu' veloce con deposits ma per ora va bene cosi'
    # sum = self.deposits.sum(:actual)
    sum = operations.sum(:number)
    (sum < 0) and raise Gemma::NegativeDeposit
    update_attribute(:total, sum)
  end

  def to_s
    name
  end

  def to_s_with_description
    d = description.blank? ? "" : " (#{description})"
    name + d
  end

  def self.inactive(organization)
    active_ids = organization.operations.select(:thing_id).uniq.map(&:thing_id)
    organization.things.where.not(id: active_ids)
  end

  def recalculate_prices
    pc = PriceCalculator.new
    operations.ordered.each do |o|
      price = 0
      price_operations = []

      if o.number > 0
        pc.add(o)
      elsif o.number < 0
        number = -1 * o.number
        while number > 0
          (stack_operation, n, p) = pc.get(number)

          stack_price = n * p

          if stack_price > 0
            if stack_operation.is_a?(Load)
              ddt = stack_operation.ddt
              price_operations << {id: stack_operation.id, n: n, p: stack_price, desc: "#{ddt.gen} n. #{ddt.number}"}
            elsif stack_operation.is_a?(Takeover)
              price_operations << {id: stack_operation.id, n: n, p: stack_price, desc: "reso da #{stack_operation.recipient.upn}"}
            elsif stack_operation.is_a?(Stock)
              price_operations << {id: stack_operation.id, n: n, p: stack_price, desc: "giacenza iniziale"}
            end
          end

          price += stack_price
          number -= n
        end
        price = price.to_i
        if o.price != price || o.price_operations != price_operations
          o.update_columns(price: price, price_operations: price_operations)
        end
      end
    end
    update_columns(future_prices: pc.remaining_stack)
  end

  def generate_barcode
    str = "g-#{id}"
    barcodes.create(organization_id: organization_id, name: str)
  end

  def under_minimum?
    total <= minimum
  end

  protected

  def strip_name_blanks
    self.name = name.squish
  end

  def convert_dewars_to_integers
    if dewars.is_a?(Array)
      self.dewars = dewars.map(&:to_i).select { |c| c > 0 }
    end
  end

  def check_group_organization
    (group.organization_id == organization_id) or raise DmUniboCommon::MismatchOrganization, "Struttura non permessa."
  end

  def check_no_associated_moves
    # FIXME: BUG risultano certe operations senza moves... da riflettere e sistemare
    if moves.any? || operations.any?
      errors.add(:base, "Ci sono carichi e scarichi associati a questo articolo che devono prima essere cancellati.")
      throw :abort
    end
  end
end
