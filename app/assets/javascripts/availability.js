window.jQuery(document).ready(() => {
  let au2 = new AvailabilityUpdater2
  au2.request_availability();
  au2.scsb_search_availability();
});
