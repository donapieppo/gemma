class Image < ApplicationRecord
  belongs_to :user
  belongs_to :thing, dependent: :destroy

  has_one_attached :photo
end

