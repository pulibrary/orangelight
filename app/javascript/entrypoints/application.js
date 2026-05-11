import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6';
import AvailabilityUpdater from '../orangelight/availability_updater.js';
import { luxImport } from '../orangelight/lux_import';
import Blacklight from 'blacklight-frontend';
import BlacklightRangeLimit from 'blacklight-range-limit';

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader();
  loader.run();

  new AvailabilityUpdater();
});

// Wait for the modal to open
document.addEventListener('show.blacklight.blacklight-modal', function () {
  // Wait for the form to be submitted successfully
  $('.modal_form').on('ajax:success', function () {
    Blacklight.Modal.hide();
  });
});

BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

window.luxImport = luxImport;
luxImport();
