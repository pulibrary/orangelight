// Focus on first non-hidden input when a modal loads.
Blacklight.onLoad( () => $("body").on("shown.bs.modal", function(event) {
  $(event.target).find('input[type!="hidden"]').first().focus();
}));
