# utililzzata per la ricerca di account da nome e cognome
# e per recuperare gli utenti gia' comparsi in una certa struttura
class DsausersController < ApplicationController
  def popup_find
    authorize :dsauser
    @cache_users = User.all_in_cache(current_organization.id)
    render layout: nil
  end

  def find
    authorize :dsauser
    str = params[:dsauser][:nome] + ' ' + params[:dsauser][:cognome]
    logger.info("DsaSearch for #{str}")
    @dsa_result = User.search(str)
    respond_to do |format|
      format.turbo_stream 
    end
  end
end
