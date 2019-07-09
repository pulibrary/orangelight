// From blacklight gem

// A function used as an event handler on loaded.blacklight.ajax-modal
// to catch contained data-ajax-modal=closed directions
Blacklight.modal.check_close_ajax_modal = function(event) {
  if ($(event.target).find(Blacklight.modal.modalCloseSelector).length) {
    modal_flashes = $(this).find('.flash_messages');

    window.setTimeout(function(){
      $(event.target).modal("hide");
    }, 2000);
    event.preventDefault();
  }
}
