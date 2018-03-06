jQuery ->
  window.plum_viewer_loader = new PlumViewerLoader($("#view"))
class PlumViewerLoader
  constructor: (@element) ->
    return unless this.element.length > 0
    if this.iiif_manifest_url()
      this.fetch_viewer_with_url(this.iiif_manifest_url())
    else
      this.fetch_viewer_from_ark("https://figgy.princeton.edu")
        .fail( () =>
          this.fetch_viewer_from_ark("https://plum.princeton.edu")
        )

  # Update the Open Graph metadata within <meta> elements
  # @param {Object} manifest - Data retrieved from a IIIF image resource
  update_open_graph_metadata: (manifest) ->
    manifest_url = manifest['url']
    $.getJSON(manifest_url).done((manifest) =>
      thumbnail = manifest['thumbnail']
      thumbnail_url = thumbnail['@id']

      og_image_elements = $('meta[property="og:image"]')
      if og_image_elements.length
        og_image_element = $(og_image_elements[0])
        og_image_element.prop('content', thumbnail_url)
      else
        og_image_element = $("<meta property=\"og:image\" content=\"#{thumbnail_url}\">")
        $("head").append(og_image_element)
    )

  fetch_viewer_from_ark: (repo_url) ->
    $.getJSON("#{repo_url}/iiif/lookup/#{this.ark()}?no_redirect=true")
      .done( this.update_open_graph_metadata, (manifest) =>
        manifest_url = manifest['url']
        this.build_viewer(manifest_url)
      )
  fetch_viewer_with_url: (url) ->
      this.build_viewer(url)
  ark: ->
    this.element.data("ark")
  iiif_manifest_url: ->
    this.element.data("iiif-manifest-url")
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
    this.element.before($("<hr class='clear'/><div class='uv__overlay' onClick='style.pointerEvents=\"none\"'></div>"))
