import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6';
import { luxImport } from '../orangelight/lux_import';
import BlacklightRangeLimit from 'blacklight-range-limit';

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader();
  loader.run();
});

BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

luxImport();
