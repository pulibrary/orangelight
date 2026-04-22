// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
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
//= require csrf_form_helper

document.addEventListener('show.blacklight.blacklight-modal', function () {
  console.log('Modal is going to be shown');
  document.querySelectorAll('.modal_form').forEach(function (form) {
    form.addEventListener(
      'submit',
      function (e) {
        e.preventDefault();

        var action = form.getAttribute('action') || window.location.href;
        var method = (form.getAttribute('method') || 'GET').toUpperCase();
        var fetchOptions = { method: method };

        var formData = new FormData(form);
        console.log(
          `method: ${method}, action: ${action}, formData:, ${formData}`
        );
        console.log(formData);
        if (method !== 'GET') {
          fetchOptions.body = formData;
        }

        // otherwise we get 422 error due to missing CSRF token
        Orangelight.CsrfFormHelper.fetch(action, fetchOptions)
          .then(function (response) {
            return response.text().then(function (body) {
              if (response.ok) {
                var modalEl =
                  document.querySelector('.modal') ||
                  document.querySelector('.blacklight-modal') ||
                  document.getElementById('blacklight-modal');
                if (modalEl) {
                  modalEl.innerHTML = body;
                } else {
                  var wrapper = document.createElement('div');
                  wrapper.innerHTML = body;
                  document.body.appendChild(wrapper);
                }
              } else {
                console.error(
                  'Modal form submission failed',
                  response.status,
                  body
                );
              }
            });
          })
          .catch(function (err) {
            console.error('Modal form submission error', err);
          });
      },
      { once: true }
    );
  });
});
