class ApplicationController < DmUniboCommon::ApplicationController
  include DmUniboCommon::Controllers::Helpers

  before_action :set_current_user,
    :update_authorization,
    :force_sso_user,
    :set_current_organization,
    :log_current_user,
    :after_current_user_and_organization,
    :set_locale

  # formally accept affiliation if
  # not session booking
  # and have no authorization in current_organization
  def after_current_user_and_organization
    if current_organization
      if session[:booking] != current_organization.id && current_organization.booking && !policy(current_organization).unload?
        redirect_to current_organization_booking_accept_path
      end
    elsif current_user
      logger.info("No current_organization for #{params[:__org__]}. Redirect #{current_user&.upn} to home")
      redirect_to home_path(__org__: nil)
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

  def fix_prices(p, add_iva)
    p[:price_int] = BigDecimal(p[:price_int])
    p[:price_dec] = BigDecimal(p[:price_dec])
    add_iva = BigDecimal(add_iva)

    price = (p[:price_int] * 100 + p[:price_dec]).to_f
    if price > 0 && add_iva > 0
      price *= ((100 + add_iva) / 100)
      p[:price_int] = (price / 100).to_i
      p[:price_dec] = (price - ((price / 100).to_i * 100)).to_i
    end
    p
  end
end
