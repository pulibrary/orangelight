<!-- This Vue component is responsible for displaying the
    overall availability status of a Holding Group, based
    on the availability info it can find in the DOM
-->
<template>
  <span ref="dom-element">
    <LuxBadge v-if="status" :color="color">{{ status }}</LuxBadge>
  </span>
</template>
<script setup>
import { computed, onMounted, ref, useTemplateRef } from 'vue';
import { LuxBadge } from 'lux-design-system';

const domElement = useTemplateRef('dom-element');
const status = ref(null);

const color = computed(() => {
  if (status.value === 'Request') {
    return 'gray';
  } else {
    return 'green';
  }
});

function selectAll(selector) {
  return domElement.value?.closest('details')?.querySelectorAll(selector);
}

function availabilityInformationHasLoaded() {
  const holdingBlocksNotYetLoaded = -1;
  const loadedValuesCount = selectAll('.availability-icon')
    ? Array.from(selectAll('.availability-icon')).filter(
        (el) => el.textContent.trim() !== ''
      ).length
    : 0;
  const holdingBlockCount =
    selectAll('.holding-block')?.length || holdingBlocksNotYetLoaded;
  return holdingBlockCount === loadedValuesCount;
}

function summary() {
  const availabilityLabels = Array.from(selectAll('.availability-icon')).map(
    (el) => el.textContent
  );
  if (
    availabilityLabels.every((label) =>
      ['Available', 'On-site Access'].includes(label.trim())
    )
  ) {
    return 'Available';
  } else if (
    availabilityLabels.every((label) =>
      ['Unavailable', 'Ask Staff'].includes(label.trim())
    )
  ) {
    return 'Request';
  } else {
    return 'Some Available';
  }
}

function getLabelFromDom(attemptNumber) {
  if (attemptNumber > 5) {
    return;
  }
  if (availabilityInformationHasLoaded()) {
    status.value = summary();
  } else {
    setTimeout(
      () => getLabelFromDom(attemptNumber + 1),
      // Give a bit more space between each attempt
      500 * attemptNumber
    );
  }
}

onMounted(() => {
  getLabelFromDom(0);
});
</script>
