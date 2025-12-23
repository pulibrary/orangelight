// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require rails-ujs
//= require popper
//
//= require bootstrap
//
// Required by Blacklight
//= require blacklight/blacklight
//= require babel/polyfill

// Wait for the modal to open
document.addEventListener('show.blacklight.blacklight-modal', function () {
  // Attach a vanilla submit handler to modal forms that submits via fetch
  // and hides the Blacklight modal on a successful response. We mark forms
  // that we've attached to so we don't double-bind when the modal reopens.
  document.querySelectorAll('.modal_form').forEach(function (form) {
    if (form.dataset.vanillaHandlerAdded) return;
    form.dataset.vanillaHandlerAdded = 'true';

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var action = form.getAttribute('action') || window.location.href;
      var method = (form.getAttribute('method') || 'GET').toUpperCase();
      var fetchOptions = { method: method, credentials: 'same-origin' };

      var formData = new FormData(form);

      if (method === 'GET') {
        // Append form data to query string for GET
        var params = new URLSearchParams(formData);
        action += (action.indexOf('?') === -1 ? '?' : '&') + params.toString();
      } else {
        fetchOptions.body = formData;
      }

      fetch(action, fetchOptions)
        .then(function (response) {
          if (response.ok) {
            Blacklight.Modal.hide();
          } else {
            return response.text().then(function (body) {
              console.error(
                'Modal form submission failed',
                response.status,
                body
              );
            });
          }
        })
        .catch(function (err) {
          console.error('Modal form submission error', err);
        });
    });
  });
});
