class Department < ApplicationRecord
  has_many :delegations
  has_many :operations

end


