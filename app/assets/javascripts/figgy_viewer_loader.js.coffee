(->
  FiggyViewerLoader = undefined
  jQuery ->
    arks_length = $("#arks_length").html()
    if arks_length
      i = 0
      while i < arks_length
        if i == 0
          window.figgy_viewer_loader = new FiggyViewerLoader($('#view'))
        else
          window.figgy_viewer_loader = new FiggyViewerLoader($('#view' + '_' + i))
        i++
      
  FiggyViewerLoader = do ->
    'var FiggyViewerLoader'

    FiggyViewerLoader = (_at_element) ->
      @element = _at_element
      if !(@element.length > 0)
        return
      if @iiif_manifest_url()
        @fetch_viewer_with_url @iiif_manifest_url()
      else
        @fetch_viewer_from_ark 'https://figgy.princeton.edu'
      return

    FiggyViewerLoader::fetch_viewer_from_ark = (repo_url) ->
      if @ark()
        $.getJSON(repo_url + '/iiif/lookup/' + @ark() + '?no_redirect=true').done ((_this) ->
          (manifest) ->
            manifest_url = undefined
            manifest_url = manifest['url']
            _this.build_viewer manifest_url
        )(this)

    FiggyViewerLoader::fetch_viewer_with_url = (url) ->
      @build_viewer url

    FiggyViewerLoader::ark = ->
      @element.data 'ark'

    FiggyViewerLoader::iiif_manifest_url = ->
      @element.data 'iiif-manifest-url'

    FiggyViewerLoader::build_viewer = (manifest) ->
      element = undefined
      script_tag = undefined
      element = $(document.createElement('div'))
      element.addClass 'uv'
      element.attr 'data-config', 'https://figgy.princeton.edu/uv_config.json'
      element.attr 'data-uri', manifest
      script_tag = $(document.createElement('script'))
      if @element[0].id
        script_tag.attr('id', 'embedUV' + '_' + @element[0].id)
      else
        script_tag.attr('id', 'embedUV')
      script_tag.attr 'src', 'https://figgy.princeton.edu/universalviewer/dist/uv-2.0.1/lib/embed.js'
      @element.append element
      @element.append script_tag
      @element.before $('<hr class=\'clear\'/><div class=\'uv__overlay\' onClick=\'style.pointerEvents="none"\'></div>')

    FiggyViewerLoader
  return
).call this

