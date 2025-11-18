import AvailabilityShow from './availability_show.js';
import AvailabilitySearchResults from './availability_search_results.js';

export default class AvailabilityUpdater {
  constructor() {
    if (document.querySelector('.documents-list')) {
      this.instance = new AvailabilitySearchResults();
      this.instance.request_availability();
      this.instance.scsb_search_availability();
    } else if (
      document.querySelector(".main-content *[data-availability-record='true']")
    ) {
      this.instance = new AvailabilityShow();
      this.instance.request_availability(true);
    }
  }
}
