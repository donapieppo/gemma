class Lab < ApplicationRecord
  belongs_to :organization
  has_many :operations

  validates :name, presence: true, uniqueness: {scope: :organization_id, message: "Lab con lo stesso nome già presente nella stessa struttura."}

  def to_s
    name
  end
end
