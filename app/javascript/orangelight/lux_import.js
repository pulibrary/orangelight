import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import { LuxLibraryFooter } from 'lux-design-system';
import OrangelightHeader from '../orangelight/vue_components/orangelight_header.vue';
import OnlineOptions from './vue_components/online_options.vue';

export function luxImport() {
  const app = createApp({});
  const createMyApp = () => createApp(app);

  document.addEventListener('DOMContentLoaded', () => {
    const elements = document.getElementsByClassName('lux');
    for (let i = 0; i < elements.length; i++) {
      createMyApp()
        .component('lux-library-footer', LuxLibraryFooter)
        .component('online-options', OnlineOptions)
        .component('orangelight-header', OrangelightHeader)
        .mount(elements[i]);
    }
  });
}
