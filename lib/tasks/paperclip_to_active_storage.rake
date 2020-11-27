require 'open-uri'

namespace :gemma do
  namespace :attachments do

    desc "Convert paperclip to active storage"
    task paperclip2as: :environment do
      Image.find_each do |i|
        next unless (i.id && i.photo_file_name)
        paperclip_file = Rails.root.join('public/system/images/photos/000/000').join("%03d" % i.id.to_s).join('original').join(i.photo_file_name)
        if File.file?(paperclip_file)
          resized = ImageProcessing::MiniMagick.source(paperclip_file)
                                               .resize_to_limit!(200, 200)
          i.photo.attach(io: resized, filename: i.photo_file_name, content_type: i.photo_content_type)
        end
      end
    end
  end
end
