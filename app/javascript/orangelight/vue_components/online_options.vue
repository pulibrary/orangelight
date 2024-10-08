<template>
  <LuxHyperlink :href="url" :underline="true"> Online options </LuxHyperlink>
  <LuxIconBase width="14" height="14">
    <LuxIconArrowRight></LuxIconArrowRight>
  </LuxIconBase>
</template>
<script setup>
import {
  LuxHyperlink,
  LuxIconBase,
  LuxIconArrowRight,
} from 'lux-design-system';
const props = defineProps(['documentId']);
const url = `/catalog/${props.documentId}#available-online`;
</script>
<style scoped>
a {
  margin-top: 3px;
  margin-bottom: 8px;
  display: inline-block;
}

a.lux-link-underline {
  border-bottom: var(--color-bleu-de-france) 2px solid;
}

.lux-icon {
  display: inline-block;
  color: var(--color-bleu-de-france);
}
</style>
