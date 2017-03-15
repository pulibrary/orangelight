jQuery ->
  # window.plum_viewer_loader = new PlumViewerLoader
  window.online_holdings_viewer = new OnlineHoldingsViewer
class PlumViewerLoader
  constructor: (@element) ->
    return unless this.element.length > 0
    $.getJSON("https://plum.princeton.edu/iiif/lookup/#{this.ark()}")
      .done( (data) =>
        this.build_viewer(data['@id'])
      )
  ark: ->
    this.element.data("ark")
  build_viewer: (manifest) ->
    element = $(document.createElement('div'))
    element.addClass('uv')
    element.attr('data-config', "https://plum.princeton.edu/uv_config.json")
    element.attr('data-uri', manifest)
    script_tag = $(document.createElement('script'))
    script_tag.attr('id', 'embedUV')
    script_tag.attr('src', "https://plum.princeton.edu/universalviewer/dist/uv-2.0.1/lib/embed.js")
    this.element.html("")
    this.element.append(element)
    this.element.append(script_tag)
class OnlineHoldingsViewer
  constructor: ->
    $(".electronic-access a[href^='http://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/']").each((index, element) =>
      element = $(element)
      ark = element.attr('href').replace('http://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/', '')
      $.getJSON("https://plum.princeton.edu/iiif/lookup/#{ark}")
        .done( (data) =>
          new_element = $("<a href='#' data-modal-ark='#{ark}'>&nbsp;[View]</a>")
          new_element.insertAfter(element)
        )
    )
    $("#viewer-modal").on("shown.bs.modal", ->
      modal_body = $(this).find(".modal-body").first()
      if(modal_body.html().trim() == "")
        new PlumViewerLoader(modal_body)
        console.log("Show viewer")
      else
        console.log("Don't load viewer")
        window.modal = modal_body
        console.log(modal_body.html())
    )
    $(document).on("click", "*[data-modal-ark]", (event) ->
      event.preventDefault()
      $("#viewer-modal .modal-body").attr("data-ark", $(this).attr("data-modal-ark"))
      $("#viewer-modal").modal()
    )
