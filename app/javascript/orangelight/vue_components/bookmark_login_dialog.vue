<template>
  <dialog id="bookmark-login" ref="dialog">
    <div tabindex="-1">
      <div class="dialog-title">
        <h2>Log in to save bookmarks</h2>
        <LuxInputButton
          type="button"
          variation="text"
          currentColor="black"
          @button-clicked="close"
        >
          <LuxIconBase height="14" width="14" iconName="close">
            <LuxIconClose></LuxIconClose>
          </LuxIconBase>
        </LuxInputButton>
      </div>
      <h3>Library Account Holders</h3>
      <p>
        To save bookmarks for future sessions, please
        <LuxHyperlink :href="loginUrl">log in</LuxHyperlink>
        using your library account.
      </p>
      <h3>Guests</h3>
      <p>
        Bookmarks are unable to be saved for future sessions. You can export
        your bookmarks to a citation manager each session.
      </p>
    </div>
  </dialog>
</template>
<script setup>
import {
  LuxHyperlink,
  LuxIconBase,
  LuxIconClose,
  LuxInputButton,
} from 'lux-design-system';
import { useTemplateRef } from 'vue';

const props = defineProps(['loginUrl']);
const dialog = useTemplateRef('dialog');
function close() {
  dialog.value.close();
}
</script>
