import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6';
import { luxImport } from '../orangelight/lux_import';

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader();
  loader.run();
});

luxImport();
