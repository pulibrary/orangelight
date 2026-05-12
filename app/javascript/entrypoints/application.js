import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6';
import AvailabilityUpdater from '../orangelight/availability_updater.js';
import { luxImport } from '../orangelight/lux_import';
import Blacklight from 'blacklight-frontend';
import BlacklightRangeLimit from 'blacklight-range-limit';
import '@popperjs/core';
import 'bootstrap/js/dist/alert';
import 'bootstrap/js/dist/button';
import 'bootstrap/js/dist/collapse';
import Dropdown from 'bootstrap/js/dist/dropdown';
import 'bootstrap/js/dist/modal';

import '@assets/stylesheets/application.scss';
import '@assets/fonts/Dejavu/DejaVuSansCondensed-webfont.eot';
import '@assets/fonts/Dejavu/DejaVuSansCondensed-webfont.eot?#iefix';
import '@assets/fonts/Dejavu/DejaVuSansCondensed-webfont.woff';
import '@assets/fonts/Dejavu/DejaVuSansCondensed-webfont.ttf';
import '@assets/fonts/RobotoMono/RobotoMono-Regular.ttf';
import '@assets/fonts/LibreFranklin/LibreFranklin-VariableFont_wght.ttf';
import '@assets/fonts/icons/pul-icons.ttf?llihnc';
import '@assets/fonts/icons/pul-icons.woff?llihnc';
import '@assets/fonts/icons/pul-icons.svg?llihnc#pul-icons';

window.bootstrap = { Dropdown };

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
