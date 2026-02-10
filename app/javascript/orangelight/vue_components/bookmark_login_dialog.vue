<template>
  <dialog id="bookmark-login" ref="dialog">
    <div class="dialog-content" tabindex="-1">
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
        To save bookmarks for future sessions, please log in using your library
        account.
      </p>
      <h3>Guests</h3>
      <p class="final-text">
        Bookmarks are unable to be saved for future sessions. You can export
        your bookmarks to a citation manager each session.
      </p>
    </div>
    <div class="login-button-container float-end">
      <LuxInputButton
        type="button"
        variation="outline"
        currentColor="black"
        @button-clicked="close"
        >Cancel</LuxInputButton
      >
      <LuxInputButton
        type="button"
        variation="solid"
        currentColor="white"
        @button-clicked="login"
        class="log-in-button"
        >Log In</LuxInputButton
      >
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

function login() {
  window.location.href = props.loginUrl;
}
</script>
<style scoped>
.log-in-button {
  margin-right: 20px;
  border: 0.125rem solid rgb(44, 110, 175);
}
.login-button-container {
  margin-bottom: 14px;
  padding-top: 10px;
}
.dialog-content {
  margin: 0 20px;
  /* border-top: 1px dotted var(--bs-border-color); */
}
.final-text {
  padding-bottom: 20px;
  margin-bottom: 0;
  border-bottom: 1px dotted var(--bs-border-color);
}
</style>
