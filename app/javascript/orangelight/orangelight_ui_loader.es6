import AvailabilityUpdater2 from '../orangelight/availability'
export default class OrangelightUiLoader {
  run() {
    this.setup_availability()
    this.setup_modal_focus()
  }

  setup_modal_focus() {
    $("body").on("shown.bs.modal", (event) => {
      $(event.target).find('input[type!="hidden"]').first().focus();
    })
  }

  setup_availability() {
    let au2 = new AvailabilityUpdater2
    au2.request_availability();
    au2.scsb_search_availability();
  }
}
