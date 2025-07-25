<template>
  <button class="btn btn-default checkbox bookmark_all" @click="handleClick">
    Bookmark all
  </button>
</template>
<script setup>
function allDocumentsAreBookmarked() {
  const allDocuments = document.querySelectorAll(
    '.bookmark-button button'
  )?.length;
  const bookmarkedDocuments = document.querySelectorAll(
    '.bookmark-button button[ol-state="in-bookmarks"]'
  )?.length;
  return allDocuments === bookmarkedDocuments;
}
function handleClick() {
  const selectorToClick = allDocumentsAreBookmarked()
    ? '.bookmark-button button[ol-state="in-bookmarks"]'
    : '.bookmark-button button[ol-state="not-in-bookmarks"]';
  document
    .querySelectorAll(selectorToClick)
    .forEach((button) => button.click());
}
</script>
