/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import figgy_manifest_manager from '../orangelight/figgy_manifest_manager'
import OrangelightUiLoader from '../orangelight/orangelight_ui_loader'

// Ensure that this is available for the DOM
window.FiggyManifestManager = figgy_manifest_manager

// boot stuff
Blacklight.onLoad( () => {
  const loader = new OrangelightUiLoader
  loader.run()

})
