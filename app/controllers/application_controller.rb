class ApplicationController < DmUniboCommon::ApplicationController
  before_action :set_current_user, :update_authorization, :set_current_organization, :after_current_user_and_organization, :log_current_user, :force_sso_user
  after_action :verify_authorized, except: [:who_impersonate, :impersonate, :stop_impersonating]

  # formally accept affiliation if
  # not session booking
  # and have no authorization in current_organization
  def after_current_user_and_organization
    if current_organization
      if session[:booking] != current_organization.id && current_organization.booking && (!policy(current_organization).unload?)
        redirect_to current_organization_booking_accept_path
      end
    elsif current_user
      logger.info("No current_organization for #{params[:__org__]}. Redirect #{current_user&.upn} to NO ACCESS")
      redirect_to no_access_path(__failed_org__: params[:__org__])
    end
  end

  def set_locale
    I18n.locale = :it
  end

  def send_report
    @title ||= ""
    rep = GemmaReport.new
    rep.title = @title
    rep.organization = current_organization
    rep.separator = @separator
    rep.separator_page_break = @separator_page_break
    rep.separator_first_line = @separator_first_line
    rep.separator_first_line_field = @separator_first_line_field
    filename = @title.downcase.tr(" ", "_") + ".pdf"
    send_data rep.to_pdf(@res, @fields), filename: filename, type: "application/pdf"
  end

  def fix_prices(par, with_iva)
    if par[:price_int] && par[:price_dec]
      par[:price_int] = par[:price_int].to_i
      par[:price_dec] = par[:price_dec].to_i
      if with_iva == "n"
        price = par[:price_int] * 100 + par[:price_dec] # in centesimi
        price *= IVA
        par[:price_int] = (price / 100).to_i
        par[:price_dec] = (price - ((price / 100).to_i * 100)).to_i
      end
    end
  end
end
