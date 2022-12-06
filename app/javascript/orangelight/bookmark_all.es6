export default class BookmarkAllManager {

  constructor() {
    this.element = $("#bookmark_all_input");
    this.prepopulate_value();
    this.bind_element();
  }

  prepopulate_value() {
    if ($("input.toggle-bookmark:checked").length == $("input.toggle-bookmark").length) {
      this.element.prop('checked', true);
    }
  }

  bind_element() {
    $("input.toggle-bookmark").on('click', (e) => {
      if (!e.target.checked) {
        this.element.prop('checked', false);
      } else {
        this.prepopulate_value();
      }
    });
    this.element.on('change', (c) => {
      if (c.target.checked) {
        this.bookmark_all();
      } else {
        this.unbookmark_all();
      }
    });
  }

  async bookmark_all() {
    let bookmarks = [];
    document.querySelectorAll('form.bookmark-toggle')
            .forEach((form) => {
              bookmarks.push('bookmarks[][document_id]=' + form.getAttribute("data-doc-id"));
            });
    if (bookmarks.length) {
      let param_string = '?' + bookmarks.join('&');
      let url = '/bookmarks/create';
      const response = await fetch(url, {
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
        body: param_string,
        method: 'POST'});
      if (response.ok) {
        const checkboxes = document.querySelectorAll("input.toggle-bookmark:not(:checked)");
        checkboxes.forEach((checkbox) => { checkbox.click() });
      } else {
        const data = await response.json();
        if (data && data.length && data[0]) {
          alert(data[0]);
        }
      }
    }
  }

  unbookmark_all() {
    $("input.toggle-bookmark:checked").trigger('click');
  }
}
