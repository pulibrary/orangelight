import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import {
  LuxAlert,
  LuxBadge,
  LuxLibraryFooter,
  LuxCard,
} from 'lux-design-system';
import OrangelightHeader from '../orangelight/vue_components/orangelight_header.vue';
import OnlineOptions from './vue_components/online_options.vue';
import BookmarkLoginDialog from './vue_components/bookmark_login_dialog.vue';
import MultiselectCombobox from './vue_components/multiselect_combobox.vue';

export function luxImport() {
  const app = createApp({});
  const createMyApp = () => createApp(app);

  document.addEventListener('DOMContentLoaded', () => {
    const elements = document.getElementsByClassName('lux');
    for (let i = 0; i < elements.length; i++) {
      createMyApp()
        .component('lux-alert', LuxAlert)
        .component('lux-badge', LuxBadge)
        .component('lux-library-footer', LuxLibraryFooter)
        .component('lux-card', LuxCard)
        .component('online-options', OnlineOptions)
        .component('orangelight-header', OrangelightHeader)
        .component('bookmark-login-dialog', BookmarkLoginDialog)
        .mount(elements[i]);
    }
    const vueapp = createApp({});
    const createVueApp = () => createApp(vueapp);
    const multiselects = document.getElementsByClassName(
      'multiselect-combobox'
    );
    for (let i = 0; i < multiselects.length; i++) {
      createVueApp()
        .component('multiselect-combobox', MultiselectCombobox)
        .mount(multiselects[i]);
    }
  });
}
