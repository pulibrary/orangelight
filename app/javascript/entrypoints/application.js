// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6'

// boot stuff
Blacklight.onLoad( () => {
  const loader = new OrangelightUiLoader
  loader.run()
})