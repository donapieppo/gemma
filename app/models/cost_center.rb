class CostCenter < ApplicationRecord
  belongs_to :organization
  has_many :delegations
  has_many :operations

  def to_s
    name
  end
end
