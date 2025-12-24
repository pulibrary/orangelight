// CSRF form helper to perform fetch requests with CSRF tokens included
(function () {
  var Orangelight = window.Orangelight || (window.Orangelight = {});

  function getCsrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta && meta.getAttribute('content');
  }

  function getCsrfParam() {
    var meta = document.querySelector('meta[name="csrf-param"]');
    return meta && meta.getAttribute('content');
  }

  function normalizeOptions(url, options) {
    options = options || {};
    options.method = (options.method || 'GET').toUpperCase();
    options.credentials = options.credentials || 'same-origin';
    options.headers = options.headers || {};

    var token = getCsrfToken();
    if (token) {
      options.headers['X-CSRF-Token'] = token;
    }
    options.headers['X-Requested-With'] =
      options.headers['X-Requested-With'] || 'XMLHttpRequest';
    options.headers['Accept'] =
      options.headers['Accept'] ||
      'text/javascript, text/html, application/json, application/xml';

    if (options.method === 'GET' && options.body instanceof FormData) {
      var params = new URLSearchParams();
      options.body.forEach(function (value, key) {
        params.append(key, value);
      });
      url += (url.indexOf('?') === -1 ? '?' : '&') + params.toString();
      delete options.body;
    }

    return { url: url, options: options };
  }

  function fetchWithCsrf(url, options) {
    var normalized = normalizeOptions(url, options);
    return fetch(normalized.url, normalized.options);
  }

  Orangelight.CsrfFormHelper = Orangelight.CsrfFormHelper || {};
  Orangelight.CsrfFormHelper.fetch = fetchWithCsrf;

  // Refresh function similar to rails-ujs to update hidden
  // authenticity_token inputs in forms after token rotation.
  function refreshCSRFTokens() {
    var token = getCsrfToken();
    var param = getCsrfParam();
    if (!token || !param) return;
    // Update any inputs matching the csrf param
    var selector = 'form input[name="' + param + '"]';
    document.querySelectorAll(selector).forEach(function (input) {
      input.value = token;
    });
  }

  Orangelight.CsrfFormHelper.refreshCSRFTokens = refreshCSRFTokens;

  // Hook to DOMContentLoaded so server-rendered forms have current token
  document.addEventListener('DOMContentLoaded', function () {
    refreshCSRFTokens();
  });

  window.CsrfFormHelper = window.CsrfFormHelper || Orangelight.CsrfFormHelper;
})();
