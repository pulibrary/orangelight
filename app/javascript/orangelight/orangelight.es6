export function orangelight() {
  // set placeholder on search type change
  document.querySelector('header').addEventListener('change', () => {
    const q = document.getElementById('q');
    const searchField = document.getElementById('search_field');
    q.setAttribute(
      'placeholder',
      searchField.options[searchField.selectedIndex].getAttribute(
        'data-placeholder'
      )
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

  // short pause before jumping to viewer if present
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
