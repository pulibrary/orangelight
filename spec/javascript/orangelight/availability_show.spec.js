import AvailabilityShow from '../../../app/javascript/orangelight/availability_show.js';

global.console = {
  log: vi.fn(),
  error: vi.fn(),
};

global.fetch = vi.fn();

delete window.location;
window.location = { pathname: '/catalog/123456789' };

describe('AvailabilityShow', function () {
  let availabilityShow;

  beforeEach(() => {
    document.body.setAttribute(
      'data-bibdata-base-url',
      'https://bibdata.princeton.edu'
    );
    availabilityShow = new AvailabilityShow();
    vi.clearAllMocks();
    window.location.pathname = '/catalog/123456789';
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.clearAllMocks();
  });

  test('it loads and initializes correctly', () => {
    expect(availabilityShow).toBeDefined();
    expect(availabilityShow.bibdata_base_url).toBe(
      'https://bibdata.princeton.edu'
    );
    expect(availabilityShow.availability_url).toBe(
      'https://bibdata.princeton.edu/availability'
    );
    expect(availabilityShow.status_display).toBeDefined();
    expect(availabilityShow.id).toBe('');
    expect(availabilityShow.host_id).toEqual([]);
  });

  describe('request_availability', () => {
    test('calls request_show_page_availability when availability elements exist', () => {
      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
      <td class="holding-status" data-availability-record="true"></td>
        </table>  
      </div>
      `;
      const spy = vi
        .spyOn(availabilityShow, 'request_show_page_availability')
        .mockImplementation(() => {});

      availabilityShow.request_availability(true);

      expect(spy).toHaveBeenCalledWith(true);
    });
  });

  describe('availability_url_show', () => {
    test('builds URL with just record id when no host_id', () => {
      availabilityShow.id = '123456789';
      availabilityShow.host_id = '';

      const url = availabilityShow.availability_url_show();

      expect(url).toBe(
        'https://bibdata.princeton.edu/bibliographic/availability.json?deep=true&bib_ids=123456789'
      );
    });
  });

  describe('request_scsb_single_availability', () => {
    test('makes fetch request with correct SCSB URL and processes response', async () => {
      const mockJson = {
        CU29420407: {
          itemBarcode: 'CU29420407',
          itemAvailabilityStatus: 'Available',
          errorMessage: null,
          collectionGroupDesignation: 'Shared',
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
      const processSpy = vi.spyOn(availabilityShow, 'process_scsb_single');
      const consoleLogSpy = vi
        .spyOn(console, 'log')
        .mockImplementation(() => {});

      availabilityShow.availability_url = 'http://mock_url/availability';
      availabilityShow.id = 'SCSB-15084779';

      availabilityShow.request_scsb_single_availability();
      await new Promise(setImmediate);

      expect(fetchSpy).toHaveBeenCalledWith(
        'http://mock_url/availability?scsb_id=15084779'
      );
      expect(processSpy).toHaveBeenCalledWith(mockJson);

      fetchSpy.mockRestore();
      processSpy.mockRestore();
      consoleLogSpy.mockRestore();
    });

    test('handles fetch errors properly', async () => {
      const fetchSpy = vi
        .spyOn(global, 'fetch')
        .mockRejectedValue(new Error('Network error'));
      const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

      availabilityShow.availability_url = 'http://mock_url/availability';
      availabilityShow.id = 'SCSB-15084779';

      availabilityShow.request_scsb_single_availability();
      await new Promise(setImmediate);

      expect(fetchSpy).toHaveBeenCalled();
      expect(errorSpy).toHaveBeenCalledWith(
        expect.stringContaining(
          'Failed to retrieve availability data for the SCSB record SCSB-15084779'
        )
      );

      fetchSpy.mockRestore();
      errorSpy.mockRestore();
    });
  });

  describe('request_show_page_availability', () => {
    test('calls request_scsb_single_availability for SCSB records', () => {
      window.location = { pathname: '/catalog/SCSB-15084779' };
      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true" data-record-id="SCSB-15084779" data-scsb-barcode="CU29420407"></td>
        </table>
      </div>
    `;

      const scsbSpy = vi
        .spyOn(availabilityShow, 'request_scsb_single_availability')
        .mockImplementation(() => {});
      const regularSpy = vi
        .spyOn(availabilityShow, 'request_show_availability')
        .mockImplementation(() => {});
      availabilityShow.request_show_page_availability(true);

      expect(scsbSpy).toHaveBeenCalled();
      expect(availabilityShow.id).toBe('SCSB-15084779');
      expect(regularSpy).not.toHaveBeenCalled();

      scsbSpy.mockRestore();
      regularSpy.mockRestore();
    });

    test('calls request_show_availability for non-SCSB records', () => {
      window.location = { pathname: '/catalog/9932127373506421' };
      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true" data-record-id="9932127373506421"></td>
        </table>
      </div>
    `;

      const scsbSpy = vi
        .spyOn(availabilityShow, 'request_scsb_single_availability')
        .mockImplementation(() => {});
      const regularSpy = vi
        .spyOn(availabilityShow, 'request_show_availability')
        .mockImplementation(() => {});

      availabilityShow.request_show_page_availability(true);

      expect(scsbSpy).not.toHaveBeenCalled();
      expect(regularSpy).toHaveBeenCalledWith(true);
      expect(availabilityShow.id).toBe('9932127373506421');

      scsbSpy.mockRestore();
      regularSpy.mockRestore();
    });
    test('sets id from window location pathname', () => {
      window.location.pathname = '/catalog/9987654321';
      document.body.innerHTML = '<div id="main-content"></div>';

      const spy = vi
        .spyOn(availabilityShow, 'request_show_availability')
        .mockImplementation(() => {});

      availabilityShow.request_show_page_availability(true);

      expect(availabilityShow.id).toBe('9987654321');
      expect(spy).toHaveBeenCalledWith(true);
    });
  });

  describe('update_single', () => {
    test('handles RES_SHARE$IN_RS_REQ holding specially', () => {
      const recordId = '123456789';
      const holdingRecords = {
        123456789: {
          RES_SHARE$IN_RS_REQ: {
            status_label: 'Unavailable',
            location: 'RES_SHARE$IN_RS_REQ',
          },
        },
      };

      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true" data-record-id="123456789" data-temp-location-code="RES_SHARE$IN_RS_REQ">
          <span class="availability-icon"></span>
        </td>
        </table>
      </div>
      `;

      const applySpy = vi
        .spyOn(availabilityShow, 'apply_availability_label')
        .mockImplementation(() => {});

      availabilityShow.update_single(holdingRecords, recordId);

      expect(applySpy).toHaveBeenCalled();
      expect(applySpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('process_scsb_single', () => {
    test('handles single available item', () => {
      availabilityShow.id = 'SCSB-123456';
      const itemRecords = {
        barcode123: {
          itemAvailabilityStatus: 'Available',
        },
      };

      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true" data-record-id="SCSB-123456" data-scsb-barcode="barcode123">
          <span class="availability-icon"></span>
        </td>
        </table>  
      </div>
      `;

      availabilityShow.process_scsb_single(itemRecords);

      const availabilityElement = document.querySelector('.availability-icon');
      expect(availabilityElement.classList.contains('green')).toBe(true);
      expect(availabilityElement.classList.contains('strong')).toBe(true);
      expect(availabilityElement.textContent).toBe('Available');
    });

    test('unavailable SCSB item', () => {
      availabilityShow.id = 'SCSB-123456';
      const itemRecords = {
        barcode123: {
          itemAvailabilityStatus: 'Unavailable',
        },
      };

      document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true" data-record-id="SCSB-123456" data-scsb-barcode="barcode123">
          <span class="availability-icon"></span>
        </td>
        </table>  
      </div>
      `;

      availabilityShow.process_scsb_single(itemRecords);

      const availabilityElement = document.querySelector('.availability-icon');
      expect(availabilityElement.classList.contains('red')).toBe(true);
      expect(availabilityElement.classList.contains('strong')).toBe(true);
      expect(availabilityElement.textContent).toBe('Unavailable');
    });
  });

  describe('update_availability_retrying', () => {
    test('updates show page elements with loading status', () => {
      document.body.innerHTML = `
        <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true">
          <span class="availability-icon"></span>
        </td>
        </table>
        </div>
      `;

      const setLoadingSpy = vi
        .spyOn(availabilityShow.status_display, 'setLoadingStatus')
        .mockImplementation(() => {});

      availabilityShow.update_availability_retrying();

      const element = document.querySelector('.availability-icon');
      expect(element.classList.contains('lux-text-style')).toBe(true);
      expect(setLoadingSpy).toHaveBeenCalled();
    });
  });

  describe('update_availability_undetermined', () => {
    test('updates show page elements with undetermined status', () => {
      document.body.innerHTML = `
        <div id="main-content" data-host-id="">
        <table>
        <td class="holding-status" data-availability-record="true">
          <span class="availability-icon"></span>
        </td>
        </table>
        </div>
      `;

      const setUndeterminedSpy = vi
        .spyOn(availabilityShow.status_display, 'setUndeterminedStatus')
        .mockImplementation(() => {});

      availabilityShow.update_availability_undetermined();

      expect(setUndeterminedSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('Locations with specific status', () => {
    test('handleOnSiteAccessStatus sets on-site access status', () => {
      const element = document.createElement('span');

      const result = availabilityShow.handleOnSiteAccessStatus(element);

      expect(element.classList.contains('green')).toBe(true);
      expect(element.classList.contains('strong')).toBe(true);
      expect(element.textContent).toBe('On-site access');
      expect(result).toBe(element);
    });

    test('handle_availability_status sets Ask Staff for marquand locations', () => {
      const element = document.createElement('span');
      const specialStatusLocations = ['marquand$stacks'];

      availabilityShow.handle_availability_status(
        'marquand$stacks',
        element,
        specialStatusLocations
      );

      expect(element.classList.contains('gray')).toBe(true);
      expect(element.classList.contains('strong')).toBe(true);
      expect(element.textContent).toBe('Ask Staff');
    });

    test('handle_availability_status sets Unavailable for non-marquand locations', () => {
      const element = document.createElement('span');
      const specialStatusLocations = ['RES_SHARE$IN_RS_REQ'];

      availabilityShow.handle_availability_status(
        'RES_SHARE$IN_RS_REQ',
        element,
        specialStatusLocations
      );

      expect(element.classList.contains('red')).toBe(true);
      expect(element.classList.contains('strong')).toBe(true);
      expect(element.textContent).toBe('Unavailable');
    });
  });

  test('request_availability uses fetch for Available SCSB record and calls process_scsb_single on success', async () => {
    window.location = { pathname: '/catalog/SCSB-15084779' };

    document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table> 
            <td class="holding-status" data-availability-record="true" data-record-id="SCSB-15084779" data-holding-id="16169462" data-scsb-barcode="CU29420407" data-aeon="false">
              <span class="availability-icon lux-text-style"></span>
          </td>
        </table>
      </div>
    `;

    const mockJson = {
      CU29420407: {
        itemBarcode: 'CU29420407',
        itemAvailabilityStatus: 'Unavailable',
        errorMessage: null,
        collectionGroupDesignation: 'Shared',
      },
      CU29420156: {
        itemBarcode: 'CU29420156',
        itemAvailabilityStatus: 'Available',
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
    const processSpy = vi.spyOn(availabilityShow, 'process_scsb_single');

    availabilityShow.availability_url = 'http://mock_url/availability';

    await availabilityShow.request_availability(true);
    await new Promise(setImmediate);

    expect(fetchSpy).toHaveBeenCalledWith(
      'http://mock_url/availability?scsb_id=15084779'
    );
    expect(fetchSpy).toHaveBeenCalledTimes(1);
    expect(processSpy).toHaveBeenCalledWith(mockJson);
    const holding_status =
      document.getElementsByClassName('availability-icon')[0];
    expect(holding_status.classList.contains('lux-text-style')).toBe(true);
    expect(holding_status.classList.contains('green')).toBe(true);
    expect(holding_status.textContent).toBe('Some Available');

    fetchSpy.mockRestore();
    processSpy.mockRestore();
  });

  test('request_availability uses fetch for available NON SCSB record and calls process_single on success', async () => {
    window.location = { pathname: '/catalog/9932127373506421' };

    document.body.innerHTML = `
      <div id="main-content" data-host-id="">
        <table>
          <td class="holding-status" data-availability-record="true" data-record-id="9932127373506421" data-holding-id="22514272140006421" data-temp-location-code="true">
            <span class="availability-icon"></span>
          </td>
        </table>
      </div>
    `;

    const mockJson = {
      '9932127373506421': {
        '22514272140006421': {
          on_reserve: 'N',
          location: 'annex$stacks',
          label: 'Forrestal Annex - Stacks',
          status_label: 'Available',
          copy_number: null,
          temp_location: false,
          id: '22514272140006421',
        },
      },
    };

    const mockResponse = {
      ok: true,
      status: 200,
      json: vi.fn().mockResolvedValue(mockJson),
    };

    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue(mockResponse);
    const processSpy = vi.spyOn(availabilityShow, 'process_single');

    availabilityShow.bibdata_base_url = 'http://mock_url';

    await availabilityShow.request_availability(true);
    await new Promise(setImmediate);

    expect(fetchSpy).toHaveBeenCalledWith(
      'http://mock_url/bibliographic/availability.json?deep=true&bib_ids=9932127373506421'
    );
    expect(fetchSpy).toHaveBeenCalledTimes(1);
    expect(processSpy).toHaveBeenCalledWith(mockJson);
    const holding_status =
      document.getElementsByClassName('availability-icon')[0];
    expect(holding_status.classList.contains('lux-text-style')).toBe(true);
    expect(holding_status.classList.contains('green')).toBe(true);
    expect(holding_status.textContent).toBe('Available');

    fetchSpy.mockRestore();
    processSpy.mockRestore();
  });
  test('record in temporary location shows as available', () => {
    // Set up DOM exactly like the working test
    document.body.innerHTML = `
    <div id="main-content" data-host-id="">
        <table>
      <td class="holding-status" data-availability-record="true" data-record-id="99131482032906421" data-holding-id="221065875350006421" data-temp-location-code="true">
        <span class="availability-icon"></span>
      </td>
    </table>
    </div>  
    `;

    const holding_records = {
      '99131482032906421': {
        '221065875350006421': {
          on_reserve: 'N',
          location: 'arch$newbook',
          label: 'Architecture Library - New Book Shelf',
          status_label: 'Available',
          copy_number: null,
          temp_location: true,
          id: '221065875350006421',
        },
      },
    };

    // Call update_single directly like the working update_single test does
    availabilityShow.update_single(holding_records, '99131482032906421');

    const holding_status = document.querySelector('.availability-icon');
    expect(holding_status.classList.contains('lux-text-style')).toBe(true);
    expect(holding_status.classList.contains('green')).toBe(true);
    expect(holding_status.classList.contains('strong')).toBe(true);
    expect(holding_status.textContent).toBe('Available');
  });
  test('record show page in RES_SHARE$IN_RS_REQ location shows as unavailable', () => {
    document.body.innerHTML = `
    <div id="main-content" data-host-id="">
        <table>
      <td class="holding-status" data-availability-record="true" data-record-id="99131482032906421" data-temp-location-code="RES_SHARE$IN_RS_REQ">
        <span class="availability-icon"></span>
      </td>
    </table>
    </div>  
    `;

    const holding_records = {
      '99131482032906421': {
        RES_SHARE$IN_RS_REQ: {
          on_reserve: 'N',
          location: 'RES_SHARE$IN_RS_REQ',
          label: 'Resource Sharing Library - Lending Resource Sharing Requests',
          status_label: 'Unavailable',
          copy_number: null,
          temp_location: true,
          id: 'RES_SHARE$IN_RS_REQ',
        },
      },
    };

    availabilityShow.update_single(holding_records, '99131482032906421');

    const holding_status = document.querySelector('.availability-icon');
    expect(holding_status.classList.contains('lux-text-style')).toBe(true);
    expect(holding_status.classList.contains('red')).toBe(true);
    expect(holding_status.classList.contains('strong')).toBe(true);
    expect(holding_status.textContent).toBe('Unavailable');
  });

  test('record show page for a bound-with record with two host ids', async () => {
    document.body.innerHTML = `
    <div id="main-content" data-host-id='["99125489925606421","99125489799906421"]'>
        <table>
        // holding status for host_id 99125489925606421
        <td class="holding-status" data-availability-record="true" data-record-id="99125489925606421" data-holding-id="22927374020006421" data-aeon="true" data-temp-location-code="false">
          <span class="availability-icon"></span>
        </td>
        // holding status for host_id 99125489799906421
        <td class="holding-status" data-availability-record="true" data-record-id="99125489799906421" data-holding-id="22927344410006421" data-aeon="true" data-temp-location-code="true">
          <span class="availability-icon"></span>
        </td>
        // holding status for main record 99576993506421
        <td class="holding-status" data-availability-record="true" data-record-id="99576993506421" data-holding-id="22589637990006421" data-temp-location-code="true">
          <span class="availability-icon lux-text-style green strong">Available</span>
        </td>
        <td class="holding-status" data-availability-record="true" data-record-id="99576993506421" data-holding-id="22589637250006421" data-temp-location-code="true">
          <span class="availability-icon lux-text-style green strong">Available</span>
        </td>
        </table>
    </div>
    `;

    const holding_records = {
      99576993506421: {
        22589637990006421: {
          on_reserve: 'N',
          location: 'marquand$pj',
          label:
            'Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only',
          status_label: 'Available',
          copy_number: null,
          temp_location: false,
          id: '22589637990006421',
        },
        22589637250006421: {
          on_reserve: 'N',
          location: 'recap$pa',
          label: 'ReCAP - Remote Storage',
          status_label: 'Available',
          copy_number: null,
          temp_location: false,
          id: '22589637250006421',
        },
        22927344410006421: {
          on_reserve: 'N',
          location: 'rare$ex',
          label: 'Special Collections - Rare Books',
          status_label: 'On-site Access',
          copy_number: null,
          temp_location: false,
          id: '22927344410006421',
        },
        22927374020006421: {
          on_reserve: 'N',
          location: 'rare$ex',
          label: 'Special Collections - Rare Books',
          status_label: 'On-site Access',
          copy_number: null,
          temp_location: false,
          id: '22927374020006421',
        },
      },
      99125489925606421: {
        22927374020006421: {
          on_reserve: 'N',
          location: 'rare$ex',
          label: 'Special Collections - Rare Books',
          status_label: 'On-site Access',
          copy_number: null,
          temp_location: false,
          id: '22927374020006421',
        },
      },
      99125489799906421: {
        22927344410006421: {
          on_reserve: 'N',
          location: 'rare$ex',
          label: 'Special Collections - Rare Books',
          status_label: 'On-site Access',
          copy_number: null,
          temp_location: false,
          id: '22927344410006421',
        },
      },
    };

    const mockResponse = {
      ok: true,
      status: 200,
      json: vi.fn().mockResolvedValue(holding_records),
    };

    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue(mockResponse);
    const processSpy = vi.spyOn(availabilityShow, 'process_single');

    availabilityShow.bibdata_base_url = 'http://mock_url';
    window.location.pathname = '/catalog/99576993506421';

    const update_single = vi.spyOn(availabilityShow, 'update_single');

    // request that would be made for bound-with records
    availabilityShow.request_show_page_availability(true);
    await new Promise(setImmediate);

    expect(fetchSpy).toHaveBeenCalledWith(
      'http://mock_url/bibliographic/availability.json?deep=true&bib_ids=99576993506421,99125489925606421,99125489799906421'
    );
    expect(fetchSpy).toHaveBeenCalledTimes(1);
    expect(processSpy).toHaveBeenCalledWith(holding_records);

    expect(update_single).toHaveBeenCalledTimes(3);
    expect(update_single).toHaveBeenCalledWith(
      holding_records,
      '99576993506421'
    );
    expect(update_single).toHaveBeenCalledWith(
      holding_records,
      '99125489925606421'
    );
    expect(update_single).toHaveBeenCalledWith(
      holding_records,
      '99125489799906421'
    );

    fetchSpy.mockRestore();
    processSpy.mockRestore();
    update_single.mockRestore();
  });
});
