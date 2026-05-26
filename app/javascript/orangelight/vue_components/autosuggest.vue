<script setup>
import { LuxInputAsyncSelect } from 'lux-design-system';

async function search(query) {
  if (query.length === 0) return ['none']; // show something on the page to show a query was run
  const result = await fetch(`/suggest?q=${query}`);
  const json = await result.json();
  return json || [];
}
</script>

<template>
  <LuxInputAsyncSelect
    label="Test autocomplete"
    :asyncLoadItemsFunction="search"
    placeholder="Hello"
  ></LuxInputAsyncSelect>
</template>
