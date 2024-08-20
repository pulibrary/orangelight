<template>
  <div class="container header-container">
    <lux-library-header app-name="Catalog" abbr-name="Catalog" app-url="/" theme="dark">
      <lux-menu-bar type="main-menu" :menu-items="menuItems" @menu-item-clicked="handleMenuItemClicked"></lux-menu-bar>
    </lux-library-header>
  </div>
</template>

<script setup>
import { LuxLibraryHeader, LuxMenuBar } from "lux-design-system";
import { ref, computed } from "vue";

const props = defineProps({
  loggedIn: Boolean,
  bookmarks: Number,
  netId: String
});

const currentlyLoggedIn = ref(props.loggedIn);
const currentNetId = ref(props.netId);

const accountLabel = computed(() => (currentlyLoggedIn.value && currentNetId.value) ? currentNetId.value : 'Your Account');
const bookmarksHtml = computed(() => `Bookmarks (<span class="bookmarks-count" data-role='bookmark-counter'>${props.bookmarks}</span>)`);

const accountChildren = computed(() => {
  if (currentlyLoggedIn.value) {
    return [
            {name: 'Library Account', component: 'Alma', href: '/users/sign_in?origin=%2Fredirect-to-alma', target: '_blank'},
            {name: 'Bookmarks', unsafe_name: bookmarksHtml.value, component: 'Bookmarks', href: '/bookmarks/'},
            {name: "ILL & Digitization Requests", component: 'ILL', href: '/digitization_requests/'},
            {name: 'Search History', component: 'History', href: '/search_history/'},
            {name: 'Log Out', component: 'LogOut', href: '/sign_out/'},
          ];
  } else {
    return [
            {name: 'Library Account', component: 'Alma', href: '/users/sign_in?origin=%2Fredirect-to-alma', target: '_blank'},
            {name: 'Bookmarks', unsafe_name: bookmarksHtml.value, component: 'Bookmarks', href: '/bookmarks/'},
            {name: 'Search History', component: 'History', href: '/search_history/'},
          ];
  }
})

const menuItems = computed(() => [
          {name: 'Help', component: 'Help', href: '/help/'},
          {name: 'Feedback', component: 'Feedback', href: '/feedback/'},
          {name: accountLabel.value, component: 'Account', href: '/account/', children: accountChildren.value}
        ]);

function handleMenuItemClicked(event) {
  if (event?.name === 'Library Account') {
    // Update the page with the id of the user once they have authenticated.
    // Since we don't know how long it will take the user to authenticate via CAS
    // we set up a timer to check every couple of seconds.
    const getUserIdTimer = setInterval(async function () {
      const response = await fetch('/account/user-id');
      const data = await response.json();
      if (data.user_id !== null) {
        clearInterval(getUserIdTimer);
        currentlyLoggedIn.value = true;
        currentNetId.value = data.user_id;
      }
    }, 2000);
  }
}
</script>
<style>
@keyframes fadeIn {
  0% { opacity: 0; }
  100% { opacity: 1; }
}

.header-container {
  animation: fadeIn 0.3s;
}
</style>
