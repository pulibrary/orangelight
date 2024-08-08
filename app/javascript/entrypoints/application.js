import OrangelightUiLoader from '../orangelight/orangelight_ui_loader.es6'
import { createApp } from 'vue'
import 'lux-design-system/dist/style.css'
import { LuxLibraryFooter } from 'lux-design-system'
import OrangelightHeader from '../orangelight/vue_components/orangelight_header.vue'

const app = createApp({})
const createMyApp = () => createApp(app)

document.addEventListener('DOMContentLoaded', () => {
  const elements = document.getElementsByClassName('lux')
  for (let i = 0; i < elements.length; i++) {
    createMyApp()
      .component('lux-library-footer', LuxLibraryFooter)
      .component('orangelight-header', OrangelightHeader)
      .mount(elements[i])
  }
})

// boot stuff
Blacklight.onLoad(() => {
  const loader = new OrangelightUiLoader()
  loader.run()
})
