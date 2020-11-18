# utililzzata per la ricerca di account da nome e cognome
# e per recuperare gli utenti gia' comparsi in una certa struttura
class DsausersController < ApplicationController
  def popup_find
    authorize :dsauser
    @cache_users = User.all_in_cache(current_organization.id)
  end

  def find
    authorize :dsauser
    str = params[:dsauser][:nome] + ' ' + params[:dsauser][:cognome]
    logger.info("DsaSearch for #{str}")
    @dsa_result = User.search(str)
  end
  
  #def last_recipient
  #  last_operation = current_organization.operations.where("operations.recipient_id is not null").order('date desc').first
  #  @last_recipient = last_operation ? last_operation.recipient.upn : ''
  #  render :json => { head: :ok, upn: @last_recipient }
  #end
end
  
