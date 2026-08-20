<template>
  <LuxHyperlink v-if="count > 1" :href="url" class="important-link">
    <span>{{ text }}</span>
  </LuxHyperlink>
  <LuxHyperlink
    v-else-if="
      !link.title.includes('Princeton University Library Finding Aids')
    "
    :href="link.url"
    class="important-link"
  >
    <span>{{ link.title }}</span>
    <span class="icon icon-external d-inline"></span>
  </LuxHyperlink>
</template>
<script setup>
import { LuxHyperlink } from 'lux-design-system';
const props = defineProps(['documentId', 'optionsCount', 'linkJson']);
const count = parseInt(props.optionsCount);
const url = `/catalog/${props.documentId}#available-online`;
const text = `${props.optionsCount} Online Options`;
const link = JSON.parse(props.linkJson);
</script>
<style scoped>
a {
  margin: 10px 12px;
  display: inline-block;
  font-size: 0.875rem;
}

.icon {
  padding-right: var(--space-xx-small);

  &.icon-external {
    margin-left: 6px;
    color: var(--color-grayscale-darker);
  }
}
</style>
