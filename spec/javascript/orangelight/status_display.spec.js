import StatusDisplay from '../../../app/javascript/orangelight/status_display.js';

describe('StatusDisplay', () => {
  let statusDisplay;
  let $el;

  beforeEach(() => {
    statusDisplay = new StatusDisplay();
    document.body.innerHTML = '<span id="test"></span>';
    $el = $('#test');
  });

  test('setAvailableStatus sets text and classes', () => {
    statusDisplay.setAvailableStatus($el);
    expect($el.text()).toBe('Available');
    expect($el.hasClass('green')).toBe(true);
    expect($el.hasClass('strong')).toBe(true);
  });

  test('setOnSiteAccessStatus sets text and classes', () => {
    statusDisplay.setOnSiteAccessStatus($el);
    expect($el.text()).toBe('On-site access');
    expect($el.hasClass('green')).toBe(true);
    expect($el.hasClass('strong')).toBe(true);
  });

  test('setUnavailableStatus sets text and classes', () => {
    statusDisplay.setUnavailableStatus($el);
    expect($el.text()).toBe('Unavailable');
    expect($el.hasClass('red')).toBe(true);
    expect($el.hasClass('strong')).toBe(true);
  });

  test('setRequestStatus sets text and classes', () => {
    statusDisplay.setRequestStatus($el);
    expect($el.text()).toBe('Request');
    expect($el.hasClass('gray')).toBe(true);
    expect($el.hasClass('strong')).toBe(true);
  });

  test('setAskStaffStatus sets text and classes', () => {
    statusDisplay.setAskStaffStatus($el);
    expect($el.text()).toBe('Ask Staff');
    expect($el.hasClass('gray')).toBe(true);
    expect($el.hasClass('strong')).toBe(true);
  });
});
