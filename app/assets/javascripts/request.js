// requests.js

Blacklight.onLoad(function(){
  
  //Finds any pul id fields that reference external metadata 
  // and instantiates jQuery plugin for each
  $("*[data-request-id]").each(function(i,val){
    $(val).requestManager();
  });
});

;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin to render services for library holdings

      Usage: $(selector).externalMetadata();

    No available options

    preview_path: base path of the preview
    confirm_msg: confirmation string presented to user for

    This plugin :
      - verifies the id supplied fits a PUL pattern
      - fetches a copy of the external metadata for the ID
      - if the id is not found the user is warned
      - parses the response and provides a preview of the metadata
      - to the operator for review. 
  */

    var pluginName = "requestManager";

    function Plugin( element, options ) {
        this.element = element;
        this.options = $.extend( {
          preview_path: "/metadata/",
          confirm_msg: "Is this the record you want?"
        }, options);
        this._name = pluginName;
        this.init();
    }

    Plugin.prototype = {
      init: function() {
        var opts = this.options;
        this.fetchMetadata(this.element, this.options);
      },

      // fire this after a 1 second delay on typing in the field
      // use underscore.js _.debounce method 
      fetchItemData: function(el, options) {
        $(el).keypress( _.debounce(function () {
          var id = $(el).val();
          var alert_label = "bg-info";
          var close_alert = '<button type="button" data-dismiss="alert" class="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>';

          $.getJSON(options.preview_path+id, function(data) {
            if (data.error) {
              alert_label = "bg-warning";
              var alert = "<p class='alert " + alert_label + "'>" + data.error + close_alert + "</p>";
              $("div.flash_messages").html(alert);
              return;
            }
            if (data === null){
              alert_label = "bg-warning";
              var alert = "<p class='alert " + alert_label + "'>ID Does Not Exist" + close_alert + "</p>";
              $("div.flash_messages").html(alert);
              return;
            }
            // using mustache template for now
            data['heading'] = options.confirm_msg;
            data['alert'] = alert_label; 
            var template = "<div class='alert {{alert}}'>{{heading}} \
                            {{id}} \
                            <ul>\
                            {{#fields}} \
                              <li>title: {{title}}</li> \
                              <li>publisher: {{publisher}}</li> \
                            {{/fields}} \
                            </ul>"
            template = template + close_alert + "</div>";              
            var html = Mustache.to_html(template, data);
            $("div.flash_messages").html(html);
          });
        }, 1000));
      }
    };

    

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    };

})( jQuery, window, document );