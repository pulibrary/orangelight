import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import {
  LuxAlert,
  LuxBadge,
  LuxIconArrowDown,
  LuxIconArrowRight,
  LuxIconBase,
  LuxIconSearch,
  LuxCard,
  LuxLibraryFooter,
  LuxShowMore,
  LuxTextStyle,
} from 'lux-design-system';
import OrangelightHeader from '../orangelight/vue_components/orangelight_header.vue';
import OnlineOptions from './vue_components/online_options.vue';
import BookmarkLoginDialog from './vue_components/bookmark_login_dialog.vue';
import MultiselectCombobox from './vue_components/multiselect_combobox.vue';
import BookmarkAllButton from './vue_components/bookmark_all_button.vue';
import BookmarkButton from './vue_components/bookmark_button.vue';
import HoldingGroupAvailability from './vue_components/holding_group_availability.vue';

export function luxImport() {
  const elements = document.getElementsByClassName('lux');
  for (let i = 0; i < elements.length; i++) {
    const el = elements[i];
    if (!el || el.dataset.vueMounted) continue; // Skip if already mounted or null
    const app = createApp({});
    app
      .component('lux-alert', LuxAlert)
      .component('lux-badge', LuxBadge)
      .component('lux-icon-arrow-down', LuxIconArrowDown)
      .component('lux-icon-arrow-right', LuxIconArrowRight)
      .component('lux-icon-base', LuxIconBase)
      .component('lux-icon-search', LuxIconSearch)
      .component('lux-library-footer', LuxLibraryFooter)
      .component('lux-card', LuxCard)
      .component('lux-show-more', LuxShowMore)
      .component('lux-text-style', LuxTextStyle)
      .component('online-options', OnlineOptions)
      .component('orangelight-header', OrangelightHeader)
      .component('bookmark-login-dialog', BookmarkLoginDialog)
      .component('bookmark-all-button', BookmarkAllButton)
      .component('bookmark-button', BookmarkButton)
      .component('holding-group-availability', HoldingGroupAvailability)
      .mount(el);
    el.dataset.vueMounted = 'true';
  }

  const multiselects = document.getElementsByClassName('multiselect-combobox');
  for (let i = 0; i < multiselects.length; i++) {
    const el = multiselects[i];
    if (!el || el.dataset.vueMounted) continue;
    const app = createApp({});
    app.component('multiselect-combobox', MultiselectCombobox).mount(el);
    el.dataset.vueMounted = 'true';
  }
}
