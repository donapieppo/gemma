class OperationMailer < ApplicationMailer
  add_template_helper(PriceHelper)

  def notify_unload(unload)
    @unload       = unload
    @user         = @unload.user
    @thing        = @unload.thing
    @organization = @thing.organization
    mail(to: @user.mail,
         subject: "Avviso di scarico materiale")
  end

  def notify_unload_to_recipient(unload)
    @unload       = unload
    @user         = @unload.user
    @recipient    = @unload.recipient
    @thing        = @unload.thing
    @organization = @thing.organization
    mail(to:       @recipient.mail,
         reply_to: @user.mail, 
         subject:  "Avviso di scarico materiale a suo nome")
  end

  def notify_minimum(unload)
    @unload       = unload
    @thing        = @unload.thing
    @organization = @thing.organization
    mail(to: @organization.adminmail,
         subject: "Raggiungimento minimo di #{@thing}")
  end

end
