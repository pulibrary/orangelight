<template>
  <div v-if="count > 1" class="online-wrapper">
    <LuxHyperlink :href="url">
      <span>{{ title }}</span>
    </LuxHyperlink>
  </div>
  <LuxHyperlink :href="link.url" v-else>
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

.lux-link {
  display: block;
  padding: 0.5rem;
  border: solid 2px var(--color-grayscale-lighter);
  border-radius: 8px;
  margin: 0;
  span {
    color: var(--color-bleu-de-france-dark);
  }
}

.lux-link:hover {
  text-decoration: none;
  color: var(--color-princeton-orange-50);
}

.icon {
  padding-right: var(--space-xx-small);

  &.icon-external {
    margin-left: 6px;
    color: var(--color-grayscale-darker);
  }
}
</style>
