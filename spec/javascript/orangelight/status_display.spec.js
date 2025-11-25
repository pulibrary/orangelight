import StatusDisplay from '../../../app/javascript/orangelight/status_display.js';

describe('StatusDisplay', () => {
  let statusDisplay;
  let element;

  beforeEach(() => {
    statusDisplay = new StatusDisplay();
    document.body.innerHTML = '<span id="test"></span>';
    element = document.getElementById('test');
  });

  test('setAvailableStatus sets text and classes', () => {
    statusDisplay.setAvailableStatus(element);
    expect(element.textContent).toBe('Available');
    expect(element.classList.contains('green')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setOnSiteAccessStatus sets text and classes', () => {
    statusDisplay.setOnSiteAccessStatus(element);
    expect(element.textContent).toBe('On-site access');
    expect(element.classList.contains('green')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setUnavailableStatus sets text and classes', () => {
    statusDisplay.setUnavailableStatus(element);
    expect(element.textContent).toBe('Unavailable');
    expect(element.classList.contains('red')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setRequestStatus sets text and classes', () => {
    statusDisplay.setRequestStatus(element);
    expect(element.textContent).toBe('Request');
    expect(element.classList.contains('gray')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setAskStaffStatus sets text and classes', () => {
    statusDisplay.setAskStaffStatus(element);
    expect(element.textContent).toBe('Ask Staff');
    expect(element.classList.contains('gray')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setSomeAvailableStatus sets text and classes', () => {
    statusDisplay.setSomeAvailableStatus(element);
    expect(element.textContent).toBe('Some Available');
    expect(element.classList.contains('green')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setUndeterminedStatus sets text and classes', () => {
    statusDisplay.setUndeterminedStatus(element);
    expect(element.textContent).toBe('Undetermined');
    expect(element.classList.contains('gray')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });

  test('setLoadingStatus sets text and classes', () => {
    statusDisplay.setLoadingStatus(element);
    expect(element.textContent).toBe('Loading...');
    expect(element.classList.contains('gray')).toBe(true);
    expect(element.classList.contains('strong')).toBe(true);
  });
});
