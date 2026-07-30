# Deposit rappresenta la relazione thing - location
# e' in pratica il deposito effettivo, l'oggetto con il posto in cui si trova
# e il numero di oggetti insieme a lui (actual)
class Deposit < ApplicationRecord
  belongs_to :thing
  belongs_to :location
  belongs_to :organization
  has_many :moves

  validates :location_id, uniqueness: {scope: :thing_id, message: "Ubicazione già presente per questo materiale.", case_sensitive: false}
  validates :organization_id, presence: {message: "Manca Struttura."}

  validate :check_thing_and_location_organization

  before_destroy :check_moves_for_delete

  def check_thing_and_location_organization
    (thing.organization_id == organization_id) or raise DmUniboCommon::MismatchOrganization, "Struttura sbagliata"
    (location.organization_id == organization_id) or raise DmUniboCommon::MismatchOrganization, "Struttura sbagliata"
  end

  def update_actual
    # self.moves.reload
    update(actual: moves.sum(:number))
  end

  private

  def check_moves_for_delete
    throw(:abort) if moves.any?
  end
end
