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

// Open the "Need Help" Lux dialogs (Ask a Question, Suggest a Correction,
// Report a Missing Item) without navigating to their feedback pages.
document.addEventListener('click', (event) => {
  const opener = event.target.closest?.('[data-open-dialog]');
  if (opener) {
    event.preventDefault();
    document.getElementById(opener.dataset.openDialog)?.showModal();
  }

  // Cancel buttons close their dialog in place.
  const closer = event.target.closest?.('[data-close-dialog]');
  if (closer) {
    closer.closest('dialog')?.close();
  }
});

BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

window.luxImport = luxImport;
luxImport();
