export default class BookmarkAllManager {
  constructor() {
    this.element = $('#bookmark_all_input');
    this.prepopulate_value();
    this.bind_element();
  }

  prepopulate_value() {
    if (
      $('input.toggle-bookmark:checked').length ==
      $('input.toggle-bookmark').length
    ) {
      this.element.prop('checked', true);
    }
  }

  bind_element() {
    $('input.toggle-bookmark').on('click', (e) => {
      if (!e.target.checked) {
        this.element.prop('checked', false);
      } else {
        this.prepopulate_value();
      }
    });
    $('.bookmark_all').on('keydown', (e) => {
      e.preventDefault();
      if (e.which == 32) {
        if (!$(e.target).find('input')[0].checked) {
          this.bookmark_all();
        } else {
          this.unbookmark_all();
        }
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

  bookmark_all() {
    document
      .querySelectorAll('input.toggle-bookmark:not(:checked)')
      .forEach((checkbox) => checkbox.click());
  }

  unbookmark_all() {
    document
      .querySelectorAll('input.toggle-bookmark:checked')
      .forEach((checkbox) => checkbox.click());
  }
}
