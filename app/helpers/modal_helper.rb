module ModalHelper
  def modal_header(title)
    %(
<div class="modal-header">
  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
  <h4 class="modal-title">#{title}</h4>
</div>).html_safe
  end

  def modal_footer(f)
    (%(
<div class="modal-footer">
  <button type="button" class="btn btn-secondary" data-dismiss="modal">Chiudi</button>) +
    f.submit("Salva", class: "btn btn-primary") + %(
</div>)).html_safe
  end
end
