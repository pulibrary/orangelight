$(function () {
  //Select all items in specific account table to be checked or unchecked
  $('body').on('change', "[id^='select-all']", function (e) {
    if (this.checked) {
      $(this)
        .closest('table')
        .find('td input:checkbox')
        .each(function (index) {
          $(this).prop('checked', true);
          $(this).closest('tr').toggleClass('info', this.checked);
        });
    } else {
      $(this)
        .closest('table')
        .find('td input:checkbox')
        .each(function (index) {
          $(this).prop('checked', false);
          $(this).closest('tr').toggleClass('info', this.checked);
        });
    }
  });

  //Add active class to tr if selected
  $('body').on('change', 'td input:checkbox', function (e) {
    $(this).closest('tr').toggleClass('info', this.checked);
  });

  // set placeholder on search type change
  const searchField = document.getElementById('search_field');
  searchField.onchange = function () {
    document
      .getElementById('q')
      .setAttribute(
        'placeholder',
        this.options[this.selectedIndex].getAttribute('data-placeholder')
      );
  };

  // short pause before jumpping to viewer if present
  document
    .getElementsByClassName('document-thumbnail')[0]
    .addEventListener('click', function (e) {
      var target = document.getElementById('viewer-container');
      if (window.location.hash === '#viewer-container') {
        var target = document.getElementById('viewer-container');
        if (target) {
          e.preventDefault();
          setTimeout(function () {
            window.scrollTo({
              top: target.offsetTop,
              behavior: 'smooth',
            });
          }, 800);
        }
      }
    });

  // preserve search query and search field on facet click

  // $('.facet-select').one('click', function (e) {
  //   if ($('#q').val()) {
  //     var query = encodeURIComponent($('#q').val());
  //     var queryDict = {};
  //     this.href
  //       .substr(1)
  //       .split('&')
  //       .forEach(function (item) {
  //         queryDict[item.split('=')[0]] = item.split('=')[1];
  //       });
  //     if (query != queryDict['q']) {
  //       if (queryDict['q'] == null) {
  //         this.href = this.href + '&q=' + query;
  //       } else {
  //         this.href = this.href.replace('&q=' + queryDict['q'], '&q=' + query);
  //       }
  //     }
  //     if ($('#search_field').val() != queryDict['search_field']) {
  //       if (queryDict['search_field'] == null) {
  //         this.href = this.href + '&search_field=' + $('#search_field').val();
  //       } else {
  //         this.href = this.href.replace(
  //           '&search_field=' + queryDict['search_field'],
  //           '&search_field=' + $('#search_field').val()
  //         );
  //       }
  //     }
  //   }
  // });
  // $('.clickable-row').on('click', function () {
  //   window.location = $(this).data('href');
  // });

  window.addEventListener('beforeprint', () => {
    document.querySelectorAll('details').forEach((element) => {
      if (element.hasAttribute('open')) element.setAttribute('opened', 'true');
      element.setAttribute('open', '');
    });
  });

  window.addEventListener('afterprint', () => {
    document.querySelectorAll('details').forEach((element) => {
      if (!element.hasAttribute('opened')) element.removeAttribute('open');
      element.removeAttribute('opened');
    });
  });
});
