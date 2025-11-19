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

  $('#search_field').on('change', function (e) {
    $('#q').attr('placeholder', $(this).find(':selected').data('placeholder'));
  });

  $('.document-thumbnail').click(function (e) {
    var target = $('#viewer-container');
    if (target.length) {
      e.preventDefault();
      $('html, body').stop().animate(
        {
          scrollTop: target.offset().top,
        },
        800
      );
    }
  });

  $('.facet-select').one('click', function (e) {
    if ($('#q').val()) {
      var query = encodeURIComponent($('#q').val());
      var queryDict = {};
      this.href
        .substr(1)
        .split('&')
        .forEach(function (item) {
          queryDict[item.split('=')[0]] = item.split('=')[1];
        });
      if (query != queryDict['q']) {
        if (queryDict['q'] == null) {
          this.href = this.href + '&q=' + query;
        } else {
          this.href = this.href.replace('&q=' + queryDict['q'], '&q=' + query);
        }
      }
      if ($('#search_field').val() != queryDict['search_field']) {
        if (queryDict['search_field'] == null) {
          this.href = this.href + '&search_field=' + $('#search_field').val();
        } else {
          this.href = this.href.replace(
            '&search_field=' + queryDict['search_field'],
            '&search_field=' + $('#search_field').val()
          );
        }
      }
    }
  });
  $('.clickable-row').on('click', function () {
    window.location = $(this).data('href');
  });

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
