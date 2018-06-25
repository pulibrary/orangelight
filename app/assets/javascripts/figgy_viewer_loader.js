(function() {
  var FiggyViewerLoader;
  FiggyViewerLoader = void 0;
  jQuery(function() {
    var arks_length, i, results;
    arks_length = $("#arks_length").html();
    if (arks_length) {
      i = 0;
      results = [];
      while (i < arks_length) {
        if (i === 0) {
          window.figgy_viewer_loader = new FiggyViewerLoader($('#view'));
        } else {
          window.figgy_viewer_loader = new FiggyViewerLoader($('#view' + '_' + i));
        }
        results.push(i++);
      }
      return results;
    }
  });
  FiggyViewerLoader = (function() {
    'var FiggyViewerLoader';
    FiggyViewerLoader = function(_at_element) {
      this.element = _at_element;
      if (!(this.element.length > 0)) {
        return;
      }
      if (this.iiif_manifest_url()) {
        this.fetch_viewer_with_url(this.iiif_manifest_url());
      } else {
        this.fetch_viewer_from_ark('https://figgy.princeton.edu');
      }
    };
    FiggyViewerLoader.prototype.fetch_viewer_from_ark = function(repo_url) {
      if (this.ark()) {
        return $.getJSON(repo_url + '/iiif/lookup/' + this.ark() + '?no_redirect=true').done((function(_this) {
          return function(manifest) {
            var manifest_url;
            manifest_url = void 0;
            manifest_url = manifest['url'];
            return _this.build_viewer(manifest_url);
          };
        })(this));
      }
    };
    FiggyViewerLoader.prototype.fetch_viewer_with_url = function(url) {
      return this.build_viewer(url);
    };
    FiggyViewerLoader.prototype.ark = function() {
      return this.element.data('ark');
    };
    FiggyViewerLoader.prototype.iiif_manifest_url = function() {
      return this.element.data('iiif-manifest-url');
    };
    FiggyViewerLoader.prototype.build_viewer = function(manifest) {
      var element, script_tag;
      element = void 0;
      script_tag = void 0;
      element = $(document.createElement('div'));
      element.addClass('uv');
      element.attr('data-config', 'https://figgy.princeton.edu/uv_config.json');
      element.attr('data-uri', manifest);
      script_tag = $(document.createElement('script'));
      if (this.element[0].id) {
        script_tag.attr('id', 'embedUV' + '_' + this.element[0].id);
      } else {
        script_tag.attr('id', 'embedUV');
      }
      this.element.append(element);
      this.element.append(script_tag);
      return this.element.before($('<hr class=\'clear\'/><div class=\'uv__overlay\' onClick=\'style.pointerEvents="none"\'></div>'));
    };
    return FiggyViewerLoader;
  })();
}).call(this);