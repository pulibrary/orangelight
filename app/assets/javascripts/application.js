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
//= require jquery_ujs
//= require popper
//
//= require bootstrap
//
// Required by Blacklight
//= require blacklight/blacklight
//= require 'blacklight_range_limit'
//= require babel/polyfill
//
//= require ./custom_range_limit.js
//= require ./orangelight.js

// Wait for the modal to open
document.addEventListener('show.blacklight.blacklight-modal', function () {
  // Add data-remote=true so that Rails UJS knows to submit the form as an AJAX request
  document
    .querySelector('#new_report_harmful_language_form')
    ?.setAttribute('data-remote', true);
  // Wait for the form to be submitted successfully
  $('.modal_form').on('ajax:success', function () {
    Blacklight.Modal.hide();
  });
  // Wait for the form to be submitted with an error
  $('.modal_form').on('ajax:error', function (event, xhr) {
    if (xhr.status == 422) {
      Blacklight.Modal.receiveAjax(xhr.responseText);
    }
  });
});
