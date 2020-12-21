class SearchController < ApplicationController
  def search
    authorize :search 

    @search_string = params[:search_string] || ''
    @search_string = @search_string.strip.gsub('%', '')
    if @search_string.length > 2
      search_things(@search_string)
      if current_user.is_cesia?
        search_admins(@search_string)
        search_organizations(@search_string)
      end
    else
      redirect_to root_path, alert: 'Si prega di raffinare la ricerca.'
    end
  end

  private

  def search_things(stringa_ricerca)
    sql_stringa = "%#{stringa_ricerca}%"
    @things = current_organization.things.includes([:group, :barcodes])
                                  .order(:name)
                                  .where('things.name LIKE ? OR things.description LIKE ? OR barcodes.name LIKE ?', sql_stringa, sql_stringa, sql_stringa)
                                  .references(:things, :barcodes)
  end

  def search_admins(stringa_ricerca)
    sql_stringa = "%#{stringa_ricerca}%"
    @permissions = DmUniboCommon::Permission.includes(:user)
                                            .group(:user_id)
                                            .where('users.name LIKE ? OR users.surname LIKE ? OR users.upn LIKE ?', sql_stringa, sql_stringa, sql_stringa)
                                            .references(:users)
  end

  def search_organizations(stringa_ricerca)
    sql_stringa = "%#{stringa_ricerca}%"
    @organizations = Organization.where('organizations.name LIKE ? OR organizations.description LIKE ? OR organizations.code LIKE ?', sql_stringa, sql_stringa, sql_stringa)
  end
end
