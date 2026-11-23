<template>
  <LuxDialog ref="dialogRef" id="bookmark-login">
    <template v-slot:title>Log in to save bookmarks</template>
    <h3>Library Account Holders</h3>
    <p>
      To save bookmarks for future sessions, please log in using your library
      account.
    </p>
    <h3>Guests</h3>
    <p class="final-text">
      Bookmarks are unable to be saved for future sessions. You can export your
      bookmarks to a citation manager each session.
    </p>
    <template v-slot:footer>
      <LuxInputButton
        type="button"
        variation="outline"
        currentColor="black"
        @button-clicked="close"
        >Cancel</LuxInputButton
      >
      <LuxHyperlink
        variation="button solid"
        :href="loginUrl"
        class="log-in-button"
        >Log In</LuxHyperlink
      >
    </template>
  </LuxDialog>
</template>
<script setup>
import { LuxDialog, LuxHyperlink, LuxInputButton } from 'lux-design-system';
import { ref } from 'vue';

const props = defineProps(['loginUrl']);
const dialogRef = ref(null);
function close() {
  dialogRef.value?.close();
}
</script>
<style scoped>
.login-button-container a.lux-link.log-in-button {
  margin-right: 20px;
  border: 0.125rem solid var(--color-bleu-de-france);
}
.login-button-container {
  margin-bottom: 14px;
  padding-top: 10px;
}
.final-text {
  padding-bottom: 20px;
  margin-bottom: 0;
  border-bottom: 1px dotted var(--bs-border-color);
}
</style>
