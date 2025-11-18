// The google books api can respond with this type of body:
// var _GBSBookInfo = {"dog": ["woof", "woof"]};
// In these cases, we only need the JSON data ({"dog": ["woof", "woof"]})
// This function cleans it up accordingly.
function cleanJson(raw) {
  const begin = raw.indexOf('{');
  const end = raw.lastIndexOf('}') + 1;
  const trimmed = raw.substring(begin, end);
  return JSON.parse(trimmed);
}

export { cleanJson };
