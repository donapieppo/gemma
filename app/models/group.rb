# Categorie in cui viene suddiviso il materiale
# all'interno della struttura.
#
# Sono una suddivisione solo estetica e non hanno molta importanza.
# Gli amministratori della struttura non possono crearle/cambiarle
class Group < ApplicationRecord
  has_many   :things, -> { order(:name) }
  belongs_to :organization

  validates :name, presence: { message: 'È necessario inserire il nome della categoria.' }
  validates :organization_id, presence: { message: "Manca l'id della struttura." }
  validates :name, uniqueness: { scope: [:organization_id], message: 'Altra categria presente con lo stesso nome.', case_sensitive: false }

  def to_s
    self.name
  end
end
