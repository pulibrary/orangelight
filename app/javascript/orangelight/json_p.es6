// Certain legacy endpoints require using a technique called JSON-P
// (see https://en.wikipedia.org/wiki/JSONP)
// Rather than doing a simple fetch() call, these endpoints (e.g. Google Books)
// require us to add a <script> tag to the DOM.  The src of the <script>
// should include the name of a callback function that will handle the
// data that is retrieved.
function requestJsonP(url) {
  const script = document.createElement('script');
  script.setAttribute('src', url);
  script.setAttribute('type', 'text/javascript');
  document.documentElement.firstChild.appendChild(script);
}

export { requestJsonP };
