# Focus on first non-hidden input when a modal loads.
Blacklight.onLoad( ->
  $("body").on("shown.bs.modal", (event) ->
    first_input = $(event.target).find('input[type!="hidden"]').first()
    first_input.focus()
  )
)
