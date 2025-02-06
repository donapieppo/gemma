# Archivio 
class ArchThing < ApplicationRecord
  belongs_to :organization
  has_many :operations, class_name: "ArchOperation", dependent: :destroy, foreign_key: :thing_id

  scope :from_new, ->(t) { where(oldid: t.id) }
end
