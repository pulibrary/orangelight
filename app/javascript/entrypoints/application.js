import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6';

import AvailabilityUpdater from '../orangelight/availability_updater.js';
import { luxImport } from '../orangelight/lux_import';
import BlacklightRangeLimit from 'blacklight-range-limit';

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader();
  loader.run();

  new AvailabilityUpdater();
});

BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

window.luxImport = luxImport;
luxImport();
