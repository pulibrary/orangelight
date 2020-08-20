export default class OrangelightUiLoader {
  run() {
    $("body").on("shown.bs.modal", (event) => {
      $(event.target).find('input[type!="hidden"]').first().focus();
    })
  }
}
