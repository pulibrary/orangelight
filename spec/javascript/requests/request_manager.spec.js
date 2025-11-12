import '../../../app/assets/javascripts/requests/requests.js';
import { describe, test, expect, beforeEach, afterEach, vi } from 'vitest';

// Access RequestManager from global scope
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/globalThis
const { RequestManager } = globalThis;

describe('RequestManager', () => {
  let requestManager, submitButton;

  beforeEach(() => {
    document.body.innerHTML = `
      <button id="request-submit-button" disabled>Submit Request</button>
      <table class="table">
        <tr id="request_1">
          <td>
            <input type="checkbox" id="requestable_selected_1" />
            <select name="requestable[][pick_up]">
              <option value="">Select pickup location</option>
              <option value="Firestone Library">Firestone Library</option>
            </select>
            <input type="radio" name="requestable[][delivery_mode]" data-target="#fields-print" />
            <input type="radio" name="requestable[][delivery_mode]" data-target="#fields-eed" />
            <input type="text" id="requestable__edd_art_title_1" />
          </td>
        </tr>
        <tr id="request_2">
          <td>
            <input type="checkbox" id="requestable_selected_2" />
          </td>
        </tr>
      </table>
      <div id="fields-print" class="collapse"></div>
      <div id="fields-eed" class="collapse"></div>
      <table class="tablesorter"></table>
    `;

    submitButton = document.getElementById('request-submit-button');
    requestManager = new RequestManager();
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('constructor and initialization', () => {
    test('should find the submit button element', () => {
      expect(requestManager.submitButton).toBe(submitButton);
    });
  });

  describe('request button management', () => {
    test('should activate request button', () => {
      expect(submitButton.disabled).toBe(true);

      requestManager._activateRequestButton();

      expect(submitButton.disabled).toBe(false);
    });

    test('should deactivate request button', () => {
      submitButton.disabled = false;

      requestManager._deactivateRequestButton();

      expect(submitButton.disabled).toBe(true);
    });
  });

  describe('requestable validation', () => {
    test('should return false when checkbox is not selected', () => {
      const row = document.getElementById('request_1');
      const checkbox = row.querySelector('input[type=checkbox]');
      checkbox.checked = false;

      const result = requestManager.requestable(row);

      expect(result).toBe(false);
    });

    test('should return true when checkbox is selected and delivery conditions are met', () => {
      const row = document.getElementById('request_1');
      const checkbox = row.querySelector('input[type=checkbox]');
      const radio = row.querySelector('input[type=radio]');
      const select = row.querySelector('select');

      checkbox.checked = true;
      radio.checked = true;
      select.selectedIndex = 1;

      const result = requestManager.requestable(row);

      expect(result).toBe(true);
    });
  });

  describe('deliveryLocation validation', () => {
    test('should return true when no pickup options exist', () => {
      const row = document.getElementById('request_2'); // No select element

      const result = requestManager.deliveryLocation(row);

      expect(result).toBe(true);
    });

    test('should return true when a valid pickup option is selected', () => {
      const row = document.getElementById('request_1');
      const select = row.querySelector('select');
      select.selectedIndex = 1;

      const result = requestManager.deliveryLocation(row);

      expect(result).toBe(true);
    });

    test('should return false when no valid pickup option is selected', () => {
      const row = document.getElementById('request_1');
      const select = row.querySelector('select');
      select.selectedIndex = 0; // Select empty option

      const result = requestManager.deliveryLocation(row);

      expect(result).toBe(false);
    });
  });

  describe('deliveryMode validation', () => {
    test('should return true when no radio buttons exist', () => {
      const row = document.getElementById('request_2'); // No radio buttons

      const result = requestManager.deliveryMode(row);

      expect(result).toBe(true);
    });

    test('should return true when a radio button is selected', () => {
      const row = document.getElementById('request_1');
      const radio = row.querySelector('input[type=radio]');
      radio.checked = true;

      const result = requestManager.deliveryMode(row);

      expect(result).toBe(true);
    });

    test('should return false when no radio button is selected', () => {
      const row = document.getElementById('request_1');

      const result = requestManager.deliveryMode(row);

      expect(result).toBe(false);
    });
  });

  describe('isEed validation', () => {
    test('should return true when EED radio is selected', () => {
      const row = document.getElementById('request_1');
      const eedRadio = row.querySelectorAll('input[type=radio]')[1]; // Second radio with EED target
      eedRadio.checked = true;

      const result = requestManager.isEed(row);

      expect(result).toBe(true);
    });

    test('should return false when non-EED radio is selected', () => {
      const row = document.getElementById('request_1');
      const standardRadio = row.querySelector('input[type=radio]'); // First radio with standard target
      standardRadio.checked = true;

      const result = requestManager.isEed(row);

      expect(result).toBe(false);
    });

    test('should return false when no radio is selected', () => {
      const row = document.getElementById('request_1');

      const result = requestManager.isEed(row);

      expect(result).toBe(false);
    });
  });

  describe('_checkRows functionality', () => {
    test('should activate button when at least one row is requestable and not EED mode', () => {
      const row = document.getElementById('request_1');
      const checkbox = row.querySelector('input[type=checkbox]');
      const radios = row.querySelectorAll('input[type=radio]');
      const printRadio = radios[0]; // First radio is print
      const select = row.querySelector('select');

      checkbox.checked = true;
      printRadio.checked = true;
      select.selectedIndex = 1;

      requestManager._checkRows();
      expect(submitButton.disabled).toBe(false);
    });

    test('should deactivate button when no rows are requestable', () => {
      // All checkboxes unchecked by default

      requestManager._checkRows();

      expect(submitButton.disabled).toBe(true);
    });

    test('should keep request button disabled when EED mode is selected and title is empty, and enable when title is present', () => {
      const row = document.getElementById('request_1');
      const checkbox = row.querySelector('input[type=checkbox]');
      const radios = row.querySelectorAll('input[type=radio]');
      const eedRadio = radios[1];
      const titleInput = document.getElementById(
        'requestable__edd_art_title_1'
      );

      expect(row).not.toBeNull();
      expect(checkbox).not.toBeNull();
      expect(eedRadio).not.toBeNull();
      expect(titleInput).not.toBeNull();

      checkbox.checked = true;
      eedRadio.checked = true;
      eedRadio.setAttribute('data-target', '#fields-eed');
      titleInput.value = '';

      requestManager._checkRows();
      expect(submitButton.disabled).toBe(true);
      // Should show validation error
      const errorElem = document.getElementById(
        'requestable__edd_art_title_1_error'
      );
      expect(errorElem).not.toBeNull();
      expect(errorElem.textContent).toContain('Title is required');

      titleInput.value = 'The best book ever';
      requestManager._checkRows();
      expect(submitButton.disabled).toBe(false);
      // Validation error should be removed
      const errorElemAfter = document.getElementById(
        'requestable__edd_art_title_1_error'
      );
      expect(errorElemAfter).toBeNull();
    });
  });

  describe('event handlers', () => {
    test('_handleEddTitleInput should deactivate button when input is empty', () => {
      const titleInput = document.getElementById(
        'requestable__edd_art_title_1'
      );
      titleInput.value = '';

      requestManager._handleEddTitleInput({ target: titleInput });

      expect(submitButton.disabled).toBe(true);
    });

    test('_handleEddTitleInput should check rows when input has value', () => {
      const titleInput = document.getElementById(
        'requestable__edd_art_title_1'
      );
      titleInput.value = 'Article Title';
      const checkRowsSpy = vi.spyOn(requestManager, '_checkRows');

      requestManager._handleEddTitleInput({ target: titleInput });

      expect(checkRowsSpy).toHaveBeenCalled();
    });

    test('handlePickupChange should check rows', () => {
      const checkRowsSpy = vi.spyOn(requestManager, '_checkRows');

      requestManager.handlePickupChange();

      expect(checkRowsSpy).toHaveBeenCalled();
    });

    test('handleCheckboxChange should toggle row selection and check rows', () => {
      const row = document.getElementById('request_1');
      const checkbox = row.querySelector('input[type=checkbox]');
      checkbox.checked = true;

      const mockEvent = { target: checkbox };
      const checkRowsSpy = vi.spyOn(requestManager, '_checkRows');

      requestManager.handleCheckboxChange(mockEvent);

      expect(row.classList.contains('selected')).toBe(true);
      expect(checkRowsSpy).toHaveBeenCalled();
    });
  });

  describe('initializeDataTable', () => {
    test('should not throw error when DataTable is not available', () => {
      expect(() => {
        requestManager.initializeDataTable();
      }).not.toThrow();
    });

    test('should initialize DataTable when jQuery and DataTable are available', () => {
      // Mock jQuery and DataTable
      const mockDataTable = vi.fn(() => ({}));
      const mockJQuery = vi.fn(() => ({ DataTable: mockDataTable }));

      global.window = { ...global.window, $: mockJQuery };
      mockJQuery.fn = { DataTable: mockDataTable };

      requestManager.initializeDataTable();

      expect(mockJQuery).toHaveBeenCalledWith(
        document.querySelector('.tablesorter')
      );
    });
  });
});
