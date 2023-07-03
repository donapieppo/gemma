class Lab < ApplicationRecord
  belongs_to :organization
  has_many :operations

  validates :name, presence: true, uniqueness: {scope: :organization_id, message: "Lab con lo stesso nome già presente nella stessa struttura."}

  before_destroy :check_operations_for_delete

  def to_s
    name
  end

  private

  def check_operations_for_delete
    throw(:abort) if self.operations.any?
  end
end
