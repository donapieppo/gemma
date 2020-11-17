class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.default_from
  layout 'mailer'
end
