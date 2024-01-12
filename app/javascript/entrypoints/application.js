import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6'

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader()
  loader.run()
})
