import AvailabilityUpdater from '../../../app/javascript/orangelight/availability_updater.js';
import AvailabilityShow from '../../../app/javascript/orangelight/availability_show.js';
import AvailabilitySearchResults from '../../../app/javascript/orangelight/availability_search_results.js';

vi.mock('../../../app/javascript/orangelight/availability_show.js');
vi.mock('../../../app/javascript/orangelight/availability_search_results.js');

describe('AvailabilityUpdater', function () {
  beforeEach(() => {
    document.body.innerHTML = '';
    vi.clearAllMocks();

    AvailabilityShow.mockClear();
    AvailabilitySearchResults.mockClear();
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.clearAllMocks();
  });

  describe('constructor - page type show or search results', () => {
    test('creates AvailabilitySearchResults instance when documents-list exists', () => {
      document.body.innerHTML = '<div class="documents-list"></div>';

      const mockSearchResults = {
        request_availability: vi.fn(),
        scsb_search_availability: vi.fn(),
      };
      AvailabilitySearchResults.mockImplementation(() => mockSearchResults);

      const updater = new AvailabilityUpdater();

      expect(AvailabilitySearchResults).toHaveBeenCalledTimes(1);
      expect(AvailabilityShow).not.toHaveBeenCalled();
      expect(updater.instance).toBe(mockSearchResults);
      expect(mockSearchResults.request_availability).toHaveBeenCalledTimes(1);
      expect(mockSearchResults.scsb_search_availability).toHaveBeenCalledTimes(
        1
      );
    });

    test('creates AvailabilityShow instance when availability elements exist but no documents-list', () => {
      document.body.innerHTML =
        '<div class="main-content"><div data-availability-record="true"></div></div>';

      const mockShow = {
        request_availability: vi.fn(),
      };
      AvailabilityShow.mockImplementation(() => mockShow);

      const updater = new AvailabilityUpdater();

      expect(AvailabilityShow).toHaveBeenCalledTimes(1);
      expect(AvailabilitySearchResults).not.toHaveBeenCalled();
      expect(updater.instance).toBe(mockShow);
      expect(mockShow.request_availability).toHaveBeenCalledWith(true);
    });

    test('does not create any instance when no relevant elements exist', () => {
      document.body.innerHTML = '<div></div>';

      const updater = new AvailabilityUpdater();

      expect(AvailabilityShow).not.toHaveBeenCalled();
      expect(AvailabilitySearchResults).not.toHaveBeenCalled();
      expect(updater.instance).toBeUndefined();
    });
  });

  describe('search results page detection', () => {
    test('calls both request_availability and scsb_search_availability for search results', () => {
      document.body.innerHTML = '<div class="documents-list"></div>';

      const mockSearchResults = {
        request_availability: vi.fn(),
        scsb_search_availability: vi.fn(),
      };
      AvailabilitySearchResults.mockImplementation(() => mockSearchResults);

      new AvailabilityUpdater();

      expect(mockSearchResults.request_availability).toHaveBeenCalledTimes(1);
      expect(mockSearchResults.scsb_search_availability).toHaveBeenCalledTimes(
        1
      );
    });
  });

  describe('when visiting a show page', () => {
    test('calls request_availability with allowRetry=true for show pages', () => {
      document.body.innerHTML =
        '<div class="main-content"><div data-availability-record="true"></div></div>';

      const mockShow = {
        request_availability: vi.fn(),
      };
      AvailabilityShow.mockImplementation(() => mockShow);

      new AvailabilityUpdater();

      expect(mockShow.request_availability).toHaveBeenCalledTimes(1);
      expect(mockShow.request_availability).toHaveBeenCalledWith(true);
    });
  });

  describe('availability updater instances', () => {
    test('exposes the created instance for search results', () => {
      document.body.innerHTML = '<div class="documents-list"></div>';

      const mockSearchResults = {
        request_availability: vi.fn(),
        scsb_search_availability: vi.fn(),
      };
      AvailabilitySearchResults.mockImplementation(() => mockSearchResults);

      const updater = new AvailabilityUpdater();

      expect(updater.instance).toBeDefined();
      expect(updater.instance).toBe(mockSearchResults);
    });

    test('exposes the created instance for show page', () => {
      document.body.innerHTML =
        '<div class="main-content"><div data-availability-record="true"></div></div>';

      const mockShow = {
        request_availability: vi.fn(),
      };
      AvailabilityShow.mockImplementation(() => mockShow);

      const updater = new AvailabilityUpdater();

      expect(updater.instance).toBeDefined();
      expect(updater.instance).toBe(mockShow);
    });

    test('it does not create an instance when no matching elements found', () => {
      document.body.innerHTML = '<div>s</div>';

      const updater = new AvailabilityUpdater();

      expect(updater.instance).toBeUndefined();
    });
  });
});
