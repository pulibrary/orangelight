export function orangelight() {
  // set placeholder on search type change
  document.querySelector('header').addEventListener('change', () => {
    const q = document.getElementById('q');
    const searchField = document.getElementById('search_field');
    q.setAttribute(
      'placeholder',
      searchField.options[searchField.selectedIndex].dataset.placeholder
    );
  });

  document.body.addEventListener('change', function (e) {
    // toggle all checkboxes if select-all clicked
    if (e.target.matches("[id^='select-all']")) {
      e.target
        .closest('table')
        .querySelectorAll('td input[type="checkbox"]')
        .forEach((checkbox) => {
          checkbox.checked = e.target.checked;
          if (checkbox.checked) {
            checkbox.closest('tr').classList.add('info');
          } else {
            checkbox.closest('tr').classList.remove('info');
          }
        });
    }

    //Add active class to tr if selected
    if (e.target.matches('td input[type="checkbox"]')) {
      e.target.closest('tr').classList.toggle('info', e.target.checked);
    }
  });

  const thumbnail = document.getElementsByClassName('document-thumbnail')[0];
  thumbnail?.addEventListener('click', function (e) {
    var target = document.getElementById('viewer-container');
    if (window.location.hash === '#viewer-container') {
      var target = document.getElementById('viewer-container');
      if (target) {
        e.preventDefault();
        // short pause before jumping to viewer if present
        setTimeout(function () {
          window.scrollTo({
            top: target.offsetTop,
            behavior: 'smooth',
          });
        }, 800);
      }
    }
  });

  function updateURL(event) {
    const q = document.getElementById('q');
    let queryDict = {};
    if (q.value) {
      const query = encodeURIComponent(q.value);
      const target = event.target;
      target.href
        .substr(1)
        .split('&')
        .forEach(function (item) {
          queryDict[item.split('=')[0]] = item.split('=')[1];
        });
      if (query != queryDict['q']) {
        if (queryDict['q'] == null) {
          target.href = target.href + '&q=' + query;
        } else {
          target.href = target.href.replace(
            '&q=' + queryDict['q'],
            '&q=' + query
          );
        }
      }
      const searchField = document.getElementById('search_field');
      if (searchField.value != queryDict['search_field']) {
        if (queryDict['search_field'] == null) {
          target.href =
            target.href +
            '&search_field=' +
            encodeURIComponent(searchField.value);
        } else {
          target.href = target.href.replace(
            '&search_field=' + queryDict['search_field'],
            '&search_field=' + encodeURIComponent(searchField.value)
          );
        }
      }
    }
  }

  document.querySelectorAll('.clickable-row').forEach((row) => {
    row.addEventListener('click', function (e) {
      window.location = e.currentTarget.href;
    });
  });

  const facets = document.querySelectorAll('.facet-select');
  facets.forEach((facet) => {
    facet.addEventListener('click', updateURL);
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
}
