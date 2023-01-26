class Move < ApplicationRecord
  belongs_to :operation
  belongs_to :deposit, optional: true
  delegate   :thing, to: :deposit

  validates :number, presence: { message: 'Manca il numero.' }
  validates :deposit_id, presence: { message: "Non è stata selezionata l'ubicazione." }
end


