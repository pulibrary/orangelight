<template>
  <div class="bookmark-button">
    <LuxInputButton variation="outline" size="small" @buttonClicked="toggle()">
      <LuxIconBase
        width="20"
        height="20"
        :iconColor="iconColor"
        :iconHide="true"
        ><LuxIconBookmark :lineColor="lineColor"></LuxIconBookmark
      ></LuxIconBase>
      <template v-if="potentialAction === 'add'">Bookmark</template>
      <template v-else>In Bookmarks</template>
    </LuxInputButton>
  </div>
</template>
<script setup>
import {
  LuxIconBase,
  LuxIconBookmark,
  LuxInputButton,
} from 'lux-design-system';
import { ref, useTemplateRef, computed, watch } from 'vue';

const props = defineProps({
  inBookmarks: { type: Boolean, default: false },
  loggedIn: { type: Boolean, default: false },
  documentId: { type: String, required: true },
});

const potentialAction = ref(props.inBookmarks ? 'remove' : 'add');
const iconColor = computed(() =>
  potentialAction.value === 'add'
    ? 'transparent'
    : 'var(--color-princeton-orange-on-white)'
);

const lineColor = computed(() =>
  potentialAction.value === 'add'
    ? 'black'
    : 'var(--color-princeton-orange-on-white)'
);

function handleMissingLocalStorageKey(key, callback) {
  if (localStorage.getItem(key)) {
    return;
  }
  localStorage.setItem(key, callback());
}

function addToBookmarks() {
  bookmarkAction('PUT', () => {
    potentialAction.value = 'remove';
  });
  if (!props.loggedIn) {
    handleMissingLocalStorageKey('catalog.bookmarks.save_account_alert', () => {
      const dialog = document.getElementById('bookmark-login');
      dialog?.showModal();
      setTimeout(() => dialog?.querySelector('.dialog-content').focus());
      return new Date(Date.now()).toISOString();
    });
  }
}

function removeFromBookmarks() {
  bookmarkAction('DELETE', () => {
    potentialAction.value = 'add';
  });
}

async function bookmarkAction(method, successCallback) {
  const response = await fetch(`/bookmarks/${props.documentId}`, {
    method: method,
    headers: {
      Accept: 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')?.content,
    },
  });
  if (response.ok) {
    const json = await response.json();
    document
      .querySelectorAll('[data-role="bookmark-counter"]')
      .forEach((counter) => {
        counter.innerHTML = json.bookmarks.count;
      });
    successCallback();
  }
}

function toggle() {
  potentialAction.value === 'add' ? addToBookmarks() : removeFromBookmarks();
}
</script>
<style>
.bookmark-button {
  display: flex;
  justify-content: end;
}
.bookmark-button button.lux-button.outline {
  display: flex;
  align-items: center;
  border: 0.125rem solid var(--color-grayscale-light);
  color: var(--color-grayscale-dark);
  width: fit-content;
  padding: 4px 8px 4px 1px;
  white-space: nowrap;
}
.bookmark-button button.lux-button.outline:hover {
  border: 0.125rem solid var(--color-grayscale-light);
  background: var(--color-grayscale-lighter);
  outline: none;
}

.bookmark-button button.lux-button.outline:focus {
  /* Don't show an outline if it gets its focus through click,
  but we will have a nice focus indicator on :focus-visible instead */
  outline: none !important;
}

.bookmark-button button.lux-button.outline:focus-visible {
  outline: var(--color-princeton-orange-on-white) solid 0.25rem !important;
}

.bookmark-button button.lux-button.outline:focus,
.bookmark-button button.lux-button.outline:focus-visible {
  outline-offset: 3px !important;
  border: 0.125rem solid var(--color-grayscale-light);
  background: var(--color-grayscale-lighter);
}
</style>
