export default class AvailabilityUpdater2 {
  constructor() { }

  record_ids() {
    return Array.from(
      document.querySelectorAll("*[data-availability-record='true'][data-record-id]")
    ).map(function(node) {
      return node.getAttribute("data-record-id")
    })
  }

  scsb_barcodes() {
    return Array.from(
      document.querySelectorAll("*[data-scsb-availability='true'][data-scsb-barcode]")
    ).map(function(node) {
      return node.getAttribute("data-scsb-barcode")
    })
  }
}
