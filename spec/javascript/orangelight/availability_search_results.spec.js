import AvailabilitySearchResults from '../../../app/javascript/orangelight/availability_search_results.js';

global.console = {
  log: vi.fn(),
  error: vi.fn(),
};

global.fetch = vi.fn();

describe('AvailabilitySearchResults', function () {
  let searchResults;

  beforeEach(() => {
    document.body.setAttribute(
      'data-bibdata-base-url',
      'https://bibdata.princeton.edu'
    );
    searchResults = new AvailabilitySearchResults();
    vi.clearAllMocks();
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.clearAllMocks();
  });

  test('it loads and initializes correctly', () => {
    expect(searchResults).toBeDefined();
    expect(searchResults.bibdata_base_url).toBe(
      'https://bibdata.princeton.edu'
    );
    expect(searchResults.availability_url).toBe(
      'https://bibdata.princeton.edu/availability'
    );
    expect(searchResults.status_display).toBeDefined();
  });

  test('request_availability calls request_search_results_availability when documents-list exists', () => {
    document.body.innerHTML = '<div class="documents-list"></div>';
    const spy = vi
      .spyOn(searchResults, 'request_search_results_availability')
      .mockImplementation(() => {});

    searchResults.request_availability();

    expect(spy).toHaveBeenCalled();
  });

  test('request_availability will not call request_search_results_availability when documents-list does not exist', () => {
    document.body.innerHTML = '<div></div>';
    const spy = vi
      .spyOn(searchResults, 'request_search_results_availability')
      .mockImplementation(() => {});

    searchResults.request_availability();

    expect(spy).not.toHaveBeenCalled();
  });

  describe('_getLibraryName', () => {
    it('returns the mapped name for an In library use location', () => {
      expect(
        searchResults._getLibraryName(
          'Marquand Library - Remote Storage (ReCAP): Firestone Library Use Only',
          'marquand$pz'
        )
      ).toBe('Marquand (Remote Storage)');
      expect(
        searchResults._getLibraryName(
          'Firestone Library - Remote Storage (ReCAP): Firestone Library Use Only',
          'firestone$pb'
        )
      ).toBe('Firestone (Remote Storage)');
      expect(
        searchResults._getLibraryName(
          'Lewis Library - Remote Storage (ReCAP): Lewis Library Use Only',
          'lewis$pn'
        )
      ).toBe('Lewis (Remote Storage)');
      expect(
        searchResults._getLibraryName(
          'Stokes Library - Remote Storage (ReCAP): Stokes Library Use Only',
          'stokes$pm'
        )
      ).toBe('Stokes (Remote Storage)');
    });
  });

  test('process_result handles temporary locations correctly', () => {
    const record_id = '99131677381406421';
    document.body.innerHTML = `
      <div class="library-location" data-location="true" data-record-id="99131677381406421" data-holding-id="engineer$res">
        <div class="results_location row">
          <svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon">
            <path d="M9.5,1.8 Q-2,4.4 9.5,17.5" stroke-width="2" fill="none"></path>
            <circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle>
          </svg>
          <span class="search-result-library-name">Engineering Library</span>
        </div>
        <div class="call-number">N350 <wbr>.Y46 2013</div>
      </div>
      <div data-availability-record="true" data-record-id="99131677381406421" data-holding-id="engineer$res">
        <span class="lux-text-style"></span>
      </div>
    `;

    const holding_records = {
      engineer$res: {
        on_reserve: 'Y',
        location: 'engineer$res',
        label: 'Engineering Library - STEM Reserves',
        status_label: 'Available',
        copy_number: null,
        temp_location: true,
        id: 'engineer$res',
      },
    };

    searchResults.process_result(record_id, holding_records);

    const availability_display = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='engineer$res'] span.lux-text-style`
    );
    expect(availability_display.classList.contains('green')).toBe(true);
    expect(availability_display.classList.contains('strong')).toBe(true);
    expect(availability_display.textContent).toEqual('Available');
  });

  test('process_result handles temporary RES_SHARE$IN_RS_REQ location correctly', () => {
    const record_id = '99131390231506421';
    document.body.innerHTML = `
      <article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="99131390231506421" data-holding-id="221044292940006421" data-temp-location-code="RES_SHARE$IN_RS_REQ" data-aeon="false" data-bound-with="false">
      <div class="library-location" data-location="true" data-record-id="99131390231506421" data-holding-id="221044292940006421">
      <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8" stroke-width="2" fill="none"></path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg>
      <span class="search-result-library-name">Firestone Library</span>
      </div>
      <div class="call-number">HF1455 <wbr>.F47 2025</div></div><span class="lux-text-style"></span>
      </article>
    `;

    const holding_records = {
      RES_SHARE$IN_RS_REQ: {
        on_reserve: 'N',
        location: 'RES_SHARE$IN_RS_REQ',
        label: 'Resource Sharing Library - Lending Resource Sharing Requests',
        status_label: 'Unavailable',
        copy_number: null,
        temp_location: true,
        id: 'RES_SHARE$IN_RS_REQ',
      },
    };

    searchResults.process_result(record_id, holding_records);

    const availability_display = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] span.lux-text-style`
    );
    expect(availability_display.classList.contains('gray')).toBe(true);
    expect(availability_display.classList.contains('strong')).toBe(true);
    expect(availability_display.textContent).toEqual('Request');
  });

  test('process_result handles temporary and non temporary locations on the same record', () => {
    const record_id = '99131688668106421';
    document.body.innerHTML = `
    <a href="/catalog/99131688668106421">
    <article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="99131688668106421" data-holding-id="221095863350006421" data-aeon="false" data-bound-with="false">
    <div class="library-location" data-location="true" data-record-id="99131688668106421" data-holding-id="221095863350006421">
    <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8" stroke-width="2" fill="none"></path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg><span class="search-result-library-name">Firestone Library</span></div><div class="call-number">NA2543<wbr>.S6 S53 2025</div></div>
    <span class="lux-text-style"></span>
    </article></a><a href="/catalog/99131688668106421">
    <article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="99131688668106421" data-holding-id="arch$fac" data-temp-location-code="arch$fac" data-aeon="false" data-bound-with="false">
    <div class="library-location" data-location="true" data-record-id="99131688668106421" data-holding-id="arch$fac">
    <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8" stroke-width="2" fill="none"></path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg><span class="search-result-library-name">Architecture Library</span></div>
    <div class="call-number">NA2543<wbr>.S6 S53 2025q Oversize</div>
    </div>
    <span class="lux-text-style"></span>
    </article></a>
    `;

    const holding_records = {
      arch$fac: {
        on_reserve: 'N',
        location: 'arch$fac',
        label:
          'Architecture Library - School of Architecture Faculty Publications',
        status_label: 'Available',
        copy_number: null,
        temp_location: true,
        id: 'arch$fac',
      },
      '221095863350006421': {
        on_reserve: 'N',
        location: 'firestone$fac',
        label: 'Firestone Library - Faculty Publications',
        status_label: 'Unavailable',
        copy_number: null,
        temp_location: false,
        id: '221095863350006421',
      },
    };

    searchResults.process_result(record_id, holding_records);

    const availability_display_temp = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='arch$fac'] span.lux-text-style`
    );
    expect(availability_display_temp.classList.contains('green')).toBe(true);
    expect(availability_display_temp.classList.contains('strong')).toBe(true);
    expect(availability_display_temp.textContent).toEqual('Available');

    const availability_display_non_temp = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='221095863350006421'] span.lux-text-style`
    );
    expect(availability_display_non_temp.classList.contains('gray')).toBe(true);
    expect(availability_display_non_temp.classList.contains('strong')).toBe(
      true
    );
    expect(availability_display_non_temp.textContent).toEqual('Request');
  });

  test('request_search_results_availability handles fetch errors', async () => {
    document.body.innerHTML = `
      <div data-availability-record="true" data-record-id="123"></div>
    `;

    fetch.mockRejectedValue(new Error('Network error'));

    searchResults.request_search_results_availability();

    await new Promise(setImmediate);

    expect(console.error).toHaveBeenCalledWith(
      expect.stringContaining('Failed to retrieve availability data for batch')
    );
  });

  test('scsb_search_availability uses fetch and calls process_barcodes on success', async () => {
    document.body.innerHTML = `
      <div class="documents-list">
        <div class="holdings-card">
          <span class="lux-text-style" data-scsb-availability="true" data-scsb-barcode="MR71868089"></span>
        </div>
        <div class="holdings-card">
          <span class="lux-text-style" data-scsb-availability="true" data-scsb-barcode="CU26842386"></span>
        </div>
        <div class="holdings-card">
          <span class="lux-text-style" data-scsb-availability="true" data-scsb-barcode="AR02546990"></span>
        </div>
      </div>
    `;

    const mockJson = {
      MR71868089: {
        itemBarcode: 'MR71868089',
        itemAvailabilityStatus: 'Available',
        errorMessage: null,
        collectionGroupDesignation: 'Shared',
      },
      CU26842386: {
        itemBarcode: 'CU26842386',
        itemAvailabilityStatus: 'Available',
        errorMessage: null,
        collectionGroupDesignation: 'Shared',
      },
      AR02546990: {
        itemBarcode: 'AR02546990',
        itemAvailabilityStatus: 'Unavailable',
        errorMessage: null,
        collectionGroupDesignation: 'Shared',
      },
    };

    const mockResponse = {
      ok: true,
      status: 200,
      json: vi.fn().mockResolvedValue(mockJson),
    };

    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue(mockResponse);
    const processSpy = vi.spyOn(searchResults, 'process_barcodes');

    searchResults.availability_url = 'http://mock_url/availability';

    await searchResults.scsb_search_availability();
    await new Promise(setImmediate);

    expect(fetchSpy).toHaveBeenCalledWith(
      'http://mock_url/availability?barcodes%5B%5D=MR71868089&barcodes%5B%5D=CU26842386&barcodes%5B%5D=AR02546990'
    );
    expect(processSpy).toHaveBeenCalledWith(mockJson);
    const holding_status_mr71868089 = document.querySelector(
      '[data-scsb-barcode="MR71868089"]'
    );
    expect(holding_status_mr71868089.textContent).toBe('Available');
    const holding_status_cu26842386 = document.querySelector(
      '[data-scsb-barcode="CU26842386"]'
    );
    expect(holding_status_cu26842386.textContent).toBe('Available');
    const holding_status_ar02546990 = document.querySelector(
      '[data-scsb-barcode="AR02546990"]'
    );
    expect(holding_status_ar02546990.textContent).toBe('Request');
    fetchSpy.mockRestore();
    processSpy.mockRestore();
  });

  describe('request_search_results_availability', () => {
    test('processes multiple bib IDs in batches for search results', async () => {
      document.body.innerHTML = `
          <div class="documents-list">
            <div class="holdings-card">
            <a href="/catalog/99125410673606421"><article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="99125410673606421" data-holding-id="22905775240006421" data-aeon="false" data-bound-with="false">
            <div class="library-location" data-location="true" data-record-id="99125410673606421" data-holding-id="22905775240006421">
            <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8"
       stroke-width="2" fill="none">
       </path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg><span class="search-result-library-name">Firestone Library</span></div>
       <div class="call-number">PN1995<wbr>.25 <wbr>.C87 2021</div></div><span class="lux-text-style strong"></span></article></a><a href="/catalog/99125410673606421"><article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="99125410673606421" data-holding-id="22909226080006421" data-aeon="false" data-bound-with="false">
       <div class="library-location" data-location="true" data-record-id="99125410673606421" data-holding-id="22909226080006421">
       <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8"
       stroke-width="2" fill="none"></path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg><span class="search-result-library-name">Marquand Library</span></div>
       <div class="call-number">PN1995<wbr>.25 <wbr>.C87 2021</div></div><span class="lux-text-style strong"></span></article></a></div>
           <div class="holdings-card">
           <a href="/catalog/9949378963506421"><article id="" class="lux-card medium holding-status" data-availability-record="true" data-record-id="9949378963506421" data-holding-id="22738013960006421" data-aeon="false" data-bound-with="false">
           <div class="library-location" data-location="true" data-record-id="9949378963506421" data-holding-id="22738013960006421">
           <div class="results_location row"><svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true" class="location-pin-icon"><path d="M9.5,1.8"
       stroke-width="2" fill="none"></path><circle r="2" fill="none" stroke-width="1.5" cx="10" cy="7.8"></circle></svg><span class="search-result-library-name">Firestone Library</span></div><div class="call-number">PN1995<wbr>.25 <wbr>.C87 2021</div></div><span class="lux-text-style strong"></span></article></a>
          </div>
        `;

      const mockJson = {
        '99125410673606421': {
          '22905775240006421': {
            on_reserve: 'N',
            location: 'firestone$stacks',
            label: 'Firestone Library - Stacks',
            status_label: 'Available',
            copy_number: null,
            temp_location: false,
            id: '22905775240006421',
          },
          '22909226080006421': {
            on_reserve: 'N',
            location: 'marquand$stacks',
            label: 'Marquand Library - Remote Storage: Marquand Use Only',
            status_label: 'Available',
            copy_number: null,
            temp_location: false,
            id: '22909226080006421',
          },
        },
        '9949378963506421': {
          '22738013960006421': {
            on_reserve: 'N',
            location: 'firestone$stacks',
            label: 'Firestone Library - Stacks',
            status_label: 'Available',
            copy_number: null,
            temp_location: false,
            id: '22738013960006421',
          },
        },
      };

      const mockResponse = {
        ok: true,
        status: 200,
        json: vi.fn().mockResolvedValue(mockJson),
      };

      const fetchSpy = vi
        .spyOn(global, 'fetch')
        .mockResolvedValue(mockResponse);
      const processSpy = vi.spyOn(searchResults, 'process_results_list');

      searchResults.bibdata_base_url = 'http://mock_url';

      searchResults.request_search_results_availability();
      await new Promise(setImmediate);
      expect(fetchSpy).not.toHaveBeenCalledWith(
        'http://mock_url/bibliographic/availability.json?bib_ids=99125410673606421,99125410673606421,9949378963506421'
      );
      expect(fetchSpy).toHaveBeenCalledWith(
        'http://mock_url/bibliographic/availability.json?bib_ids=99125410673606421,9949378963506421'
      );
      expect(processSpy).toHaveBeenCalledWith(mockJson);

      fetchSpy.mockRestore();
      processSpy.mockRestore();
    });
    test('returns early when no bib IDs are found', () => {
      document.body.innerHTML = '<div class="documents-list"></div>';

      const fetchSpy = vi.spyOn(global, 'fetch');

      searchResults.request_search_results_availability();

      expect(fetchSpy).not.toHaveBeenCalled();
      fetchSpy.mockRestore();
    });
  });

  test('request_availability uses fetch and calls process_results_list on success', async () => {
    document.body.innerHTML =
      '<div class="documents-list">' +
      '<li data-availability-record="true" data-record-id="99131592119006421"></li>' +
      '<li data-availability-record="true" data-record-id="99131494079906421"></li>' +
      '<li data-availability-record="true" data-record-id="99129167963206421"></li>' +
      '</div>';
    const mockJson = {
      '99131592119006421': {
        '221083207360006421': {
          on_reserve: 'N',
          location: 'firestone$stacks',
          label: 'Firestone Library - Stacks',
          status_label: 'Available',
          copy_number: null,
          temp_location: false,
          id: '221083207360006421',
        },
      },
      '99131494079906421': {
        '221067103950006421': {
          on_reserve: 'N',
          location: 'marquand$pj',
          label:
            'Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only',
          status_label: 'Unavailable',
          copy_number: null,
          temp_location: false,
          id: '221067103950006421',
        },
      },
      '99129167963206421': {
        '221005134130006421': {
          on_reserve: 'N',
          location: 'marquand$pj',
          label:
            'Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only',
          status_label: 'Unavailable',
          copy_number: null,
          temp_location: false,
          id: '221005134130006421',
        },
      },
    };
    const mockResponse = {
      ok: true,
      status: 200,
      json: vi.fn().mockResolvedValue(mockJson),
    };
    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue(mockResponse);
    const processSpy = vi.spyOn(searchResults, 'process_results_list');

    searchResults.bibdata_base_url = 'http://mock_url';
    await searchResults.request_availability();
    await new Promise(setImmediate); // all microtasks execute before continuing

    expect(fetchSpy).toHaveBeenCalled();
    expect(processSpy).toHaveBeenCalledWith(mockJson);

    fetchSpy.mockRestore();
    processSpy.mockRestore();
  });

  describe('update_availability_undetermined', () => {
    test('updates search results elements with undetermined status', () => {
      document.body.innerHTML = `
        <div class="documents-list">
          <div data-availability-record="true">
            <span class="lux-text-style"></span>
          </div>
        </div>
      `;

      const setUndeterminedSpy = vi
        .spyOn(searchResults.status_display, 'setUndeterminedStatus')
        .mockImplementation(() => {});

      searchResults.update_availability_undetermined();

      expect(setUndeterminedSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('update_availability_retrying', () => {
    test('updates search results elements with loading status', () => {
      document.body.innerHTML = `
        <div class="documents-list">
          <div data-availability-record="true">
            <span class="lux-text-style"></span>
          </div>
        </div>
      `;

      const setLoadingSpy = vi
        .spyOn(searchResults.status_display, 'setLoadingStatus')
        .mockImplementation(() => {});

      searchResults.update_availability_retrying();

      expect(setLoadingSpy).toHaveBeenCalledTimes(1);
    });
  });
});
