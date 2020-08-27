import AvailabilityUpdater from '../orangelight/availability'
import FiggyManifestManager from '../orangelight/figgy_manifest_manager'

export default class OrangelightUiLoader {
  run() {
    this.setup_availability()
    this.setup_modal_focus()
    this.setup_viewers()
  }

  setup_modal_focus() {
    $("body").on("shown.bs.modal", (event) => {
      $(event.target).find('input[type!="hidden"]').first().focus();
    })
  }

  setup_availability() {
    let au2 = new AvailabilityUpdater
    au2.request_availability();
    au2.scsb_search_availability();
  }

  setup_viewers() {

  }
}
