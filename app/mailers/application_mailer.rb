class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.unibo_common.default_from
  default reply_to: Rails.configuration.unibo_common.reply_to
  layout "mailer"
end
