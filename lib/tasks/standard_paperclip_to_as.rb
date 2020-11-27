require 'open-uri'

namespace :gemma do
  namespace :attachments do

    def key(instance, attachment)
      SecureRandom.uuid
    end

    desc "Convert paperclip to active storage"
    task standard_paperclip2as: :environment do

      # mariadb
      get_blob_id = 'LAST_INSERT_ID()'

      active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
        INSERT INTO active_storage_blobs (
          `key`, filename, content_type, metadata, byte_size, checksum, created_at
        ) VALUES (?, ?, ?, '{}', ?, ?, ?)
      SQL

      active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
        INSERT INTO active_storage_attachments (
          name, record_type, record_id, blob_id, created_at
        ) VALUES (?, ?, ?, #{get_blob_id}, ?)
      SQL

      Rails.application.eager_load!
      models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

      ActiveRecord::Base.transaction do
        models.each do |model|

          (model != Image) and next

          attachments = model.column_names.map do |c|
            if c =~ /(.+)_file_name$/
              $1
            end
          end.compact

          if attachments.blank?
            next
          end

          model.find_each.each do |instance|
            attachments.each do |attachment|

              p instance
              p attachment
              paperclip_file = "/home/rails/gemma/public/system/images/photos/000/000/#{"%03d" % instance.id}/original/#{instance.send(:photo_file_name)}"

              #if instance.send(attachment).path.blank?
              #  next
              #end

              p instance.send("#{attachment}_file_name")
              p instance.send("#{attachment}_content_type")
              p instance.send("#{attachment}_file_size")
              p Digest::MD5.base64digest(File.read(paperclip_file))
              # instance.send("#{attachment}_updated_at").iso8601

              p attachment
              p model.name
              p instance.id

              orig_date = instance.send("#{attachment}_updated_at").to_s.gsub(/ \+\d\d\d\d/, '') # 2012-10-05 12:28:52 +0200

              _key = key(instance, attachment)

              p active_storage_blob_statement.execute(
                  _key,
                  instance.send("#{attachment}_file_name"),
                  instance.send("#{attachment}_content_type"),
                  instance.send("#{attachment}_file_size"),
                  Digest::MD5.base64digest(File.read(paperclip_file)),
                  orig_date
              )

              p active_storage_attachment_statement.execute(
                  attachment,
                  model.name,
                  instance.id,
                  orig_date
              )

              dest_dir = File.join("/home/rails/gemma/storage", _key.first(2), _key.first(4).last(2))
              dest = File.join(dest_dir, _key)

              FileUtils.mkdir_p(dest_dir)
              puts "Coping #{paperclip_file} to #{dest}"
              FileUtils.cp(paperclip_file, dest)
            end
          end
        end
      end
    end
  end
end
