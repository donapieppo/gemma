module ApplicationHelper
  def inizio_anno
    Date.parse("01-01-#{Date.today.year}")
  end

  def inizio_prossimo_mese
    (Date.today >> 1).change(day: 1) # Return a new Date object that is n months later than the current one. 
  end

  def thing_actions_menu
    if policy(current_organization).manage?
      render partial: "shared/thing_actions_menu"
    end
  end

  def readonly_warning
    if policy(current_organization).only_read?
      content_tag(:p, 'Da questo computer avete accesso alla sola consultazione del materiale', class: "alert alert-warning", role: "alert")
    end
  end

  def barcode_scanner_link
    if request.user_agent =~ /Android/   
      '<a href="zxing://scan/?ret=https%3A%2F%2Ftester.dm.unibo.it%2Fgemma%2Fzxing_search%2F%7BCODE%7D"><i class="fas fa-barcode" style="font-size: 30px"></i></a>'.html_safe
    else
      ''
    end
  end
end

include DmUniboCommonHelper

include BookingHelper
include ThingHelper
include OperationHelper
include MoveHelper
include ReportHelper
include PriceHelper
