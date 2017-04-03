jQuery ->
  window.plum_viewer_loader = new PlumViewerLoader($("#view"))
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
    this.element.append(element)
    this.element.append(script_tag)
    this.element.before($("<hr class='clear'/>"))
