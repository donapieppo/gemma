class PickingPoint < ApplicationRecord
  has_many :delegations
  has_many :operations
end
