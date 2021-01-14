class Image < ApplicationRecord
  belongs_to :user
  belongs_to :thing

  after_create_commit :photo_format

  has_one_attached :photo

  def resize_photo
    photo.blob.open do |file|
      resized = ImageProcessing::MiniMagick.source(file)
                                           .resize_to_limit!(200, 200)
      v_filename = photo.filename
      v_content_type = photo.content_type
      photo.purge
      photo.attach(io: resized, filename: v_filename, content_type: v_content_type)
    end
  end

  private

  def photo_format
    return unless photo.attached?

    if photo.blob.content_type.start_with? 'image/'
      resize_photo
    else
      photo.purge
      errors.add(:photo, "Non hai inviato un'immagine.")
    end
  end
end
