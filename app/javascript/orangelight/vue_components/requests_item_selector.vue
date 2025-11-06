<template>
  <LuxInputMultiselect
    :asyncLoadItemsFunction="currentItems"
    label="Items to request"
  ></LuxInputMultiselect>
</template>
<script setup>
import { LuxInputMultiselect } from 'lux-design-system';
import { ref } from 'vue';

const props = defineProps({
  bibdataBase: {
    type: String,
    default: 'https://bibdata.princeton.edu',
  },
  items: {
    type: Array,
    required: true,
  },
  recordId: {
    type: String,
    required: true,
  },
  mfhdId: {
    type: String,
    required: true,
  },
});
const itemsFromBibdata = ref([]);

// Get the most recent item data we have available:
// If the `fetch` has finished, use that!
// Otherwise, use the items passed in via the prop
const currentItems = async () => {
  if (itemsFromBibdata.value.length > 0) {
    return itemsFromBibdata.value;
  } else {
    return Promise.resolve(props.items);
  }
};

const fetchUpdatedAvailability = async () => {
  const response = await fetch(
    `${props.bibdataBase}/bibliographic/${props.recordId}/holdings/${props.mfhdId}/availability.json`
  );
  const rawData = await response.json();
  itemsFromBibdata.value = rawData.map((item) => {
    return { id: item.id, label: item.description };
  });
};

fetchUpdatedAvailability();
</script>
