module MoveHelper
  def up_or_down_icon(n)
    dm_icon((n > 0) ? "arrow-circle-up" : "arrow-circle-down")
  end

  def move_action_icons(o, n)
    ((o.is_unload? && n >= -1) ? "" : link_to_edit("", [:edit, o])) +
      link_to_delete("", o) +
      ((o.is_unload? && !o.is_booking? && o.recipient) ? %(<a href="#" title="ricevuta" onClick="window.open("#{signing_unload_path(o.id)}", "ricevuta", "width=700,height=500,scrollbars=no");">#{dmicon("file")}</a>).html_safe : "")
  end
end
