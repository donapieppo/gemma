class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.default_from
  default reply_to: Rails.configuration.reply_to
  layout 'mailer'
end
