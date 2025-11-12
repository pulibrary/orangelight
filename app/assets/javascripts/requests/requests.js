// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/**
 * CollapseManager - Handles Bootstrap 5 collapse panel functionality
 */
class CollapseManager {
  /**
   * Hide a collapse panel element
   * @param {HTMLElement} element
   */
  static hide(element) {
    if (!element) return;

    if (window.bootstrap?.Collapse) {
      const collapse =
        window.bootstrap.Collapse.getInstance(element) ||
        new window.bootstrap.Collapse(element, { toggle: false });
      collapse.hide();
    } else {
      element.classList.remove('show');
    }
  }

  /**
   * Show a collapse panel element
   * @param {HTMLElement} element
   */
  static show(element) {
    if (!element) return;

    if (window.bootstrap?.Collapse) {
      const collapse =
        window.bootstrap.Collapse.getInstance(element) ||
        new window.bootstrap.Collapse(element, { toggle: false });
      collapse.show();
    } else {
      element.classList.add('show');
    }
  }

  /**
   * Hide all collapse panels associated with radio buttons of the same name
   * @param {string} radioName - The name attribute of the radio button group
   */
  static hideAllRelated(radioName) {
    const relatedRadios = document.querySelectorAll(
      `input[name="${radioName}"]`
    );

    relatedRadios.forEach((radio) => {
      const targetSelector = radio.getAttribute('data-target');
      if (targetSelector) {
        const collapseElement = document.querySelector(targetSelector);
        if (collapseElement) {
          this.hide(collapseElement);
        }
      }
    });
  }

  /**
   * Show the collapse panel associated with a specific radio button
   * @param {HTMLElement} radioButton - The radio button element
   */
  static showForRadio(radioButton) {
    const targetSelector = radioButton.getAttribute('data-target');
    if (targetSelector) {
      const collapseElement = document.querySelector(targetSelector);
      if (collapseElement) {
        this.show(collapseElement);
      }
    }
  }

  /**
   * Handle delivery mode change - hide all related panels, then show the selected one
   * @param {HTMLElement} selectedRadio - The radio button that was selected
   */
  static handleDeliveryModeChange(selectedRadio) {
    const radioName = selectedRadio.name;

    // First, hide all related panels
    this.hideAllRelated(radioName);

    // Then show the panel for the selected radio
    this.showForRadio(selectedRadio);
  }
}

class RequestManager {
  _showTitleValidationError(titleInput, errorMsgId) {
    let errorElem = document.getElementById(errorMsgId);
    if (!errorElem) {
      errorElem = document.createElement('div');
      errorElem.id = errorMsgId;
      errorElem.className = 'validation-error';
      errorElem.textContent = 'Title is required.';
      titleInput.parentNode.appendChild(errorElem);
    }
    titleInput.classList.add('is-invalid');
  }
  _eddTitleIsPresent(row) {
    const titleInput = row.querySelector(
      'input[type=text][id^="requestable__edd_art_title_"]'
    );
    return titleInput && titleInput.value.trim() !== '';
  }
  constructor() {
    this.submitButton = document.getElementById('request-submit-button');
    this.init();
  }

  init() {
    this._checkRows();
    this.bindEvents();
    this.initializeDataTable();
  }

  // Request button enable/disable logic
  _activateRequestButton() {
    if (this.submitButton) {
      this.submitButton.disabled = false;
    }
  }

  _deactivateRequestButton() {
    if (this.submitButton) {
      this.submitButton.disabled = true;
    }
  }

  // Row validation logic
  _checkRows() {
    const rows = document.querySelectorAll('tr[id^=request_]');
    let anyValidRows = false;

    for (const row of rows) {
      if (this.requestable(row)) {
        if (this.isEed(row)) {
          const titleInput = row.querySelector(
            'input[type=text][id^="requestable__edd_art_title_"]'
          );
          const errorMsgId = titleInput ? titleInput.id + '_error' : null;
          const errorElem = errorMsgId
            ? document.getElementById(errorMsgId)
            : null;
          if (!this._eddTitleIsPresent(row)) {
            this._deactivateRequestButton();
            // Show validation error if not present
            if (titleInput) {
              this._showTitleValidationError(titleInput, errorMsgId);
            }
            return;
          } else {
            // Remove validation error if present
            if (errorElem) {
              errorElem.remove();
              titleInput.classList.remove('is-invalid');
            }
          }
        }
        anyValidRows = true;
      }
    }

    if (anyValidRows) {
      this._activateRequestButton();
    } else {
      this._deactivateRequestButton();
    }
  }

  requestable(parent) {
    const checkbox = parent.querySelector(
      'input[type=checkbox][id^="requestable_selected"]'
    );
    const selected = checkbox ? checkbox.checked : false;

    return (
      selected && this.deliveryMode(parent) && this.deliveryLocation(parent)
    );
  }

  deliveryLocation(parent) {
    const requestablePickups = parent.querySelectorAll(
      'select[name^="requestable[][pick_up"] option'
    );
    let deliveryLocation = false;

    if (requestablePickups.length === 0 || this.isEed(parent)) {
      deliveryLocation = true;
    } else {
      requestablePickups.forEach((option) => {
        if (option.selected && option.value !== '') {
          deliveryLocation = true;
        }
      });
    }
    return deliveryLocation;
  }

  deliveryMode(parent) {
    const radios = parent.querySelectorAll(
      'input[type=radio][name^="requestable[][delivery_mode"]'
    );
    let deliveryMode = false;

    if (radios.length === 0) {
      deliveryMode = true;
    } else {
      radios.forEach((radio) => {
        if (radio.checked) {
          deliveryMode = true;
        }
      });
    }
    return deliveryMode;
  }

  isEed(parent) {
    const radios = parent.querySelectorAll(
      'input[type=radio][name^="requestable[][delivery_mode"]'
    );
    let eedRequest = false;

    if (radios.length > 0) {
      radios.forEach((radio) => {
        if (radio.checked) {
          eedRequest = radio.dataset.target?.startsWith('#fields-eed') || false;
        }
      });
    }
    return eedRequest;
  }

  // Bootstrap collapse integration
  _handleDeliveryModeChange(event) {
    const target = event.target;

    // Use CollapseManager to handle all collapse logic
    CollapseManager.handleDeliveryModeChange(target);

    // Show validation error if EED selected and title is empty
    const row = target.closest('tr');
    if (this.isEed(row)) {
      const titleInput = row.querySelector(
        'input[type=text][id^="requestable__edd_art_title_"]'
      );
      if (titleInput && titleInput.value.trim() === '') {
        const errorMsgId = titleInput.id + '_error';
        const errorElem = document.getElementById(errorMsgId);
        this._showTitleValidationError(titleInput, errorMsgId);
      }
    }

    // Re-validate the form after the change
    this._checkRows();
  }

  // EDD title input handler
  _handleEddTitleInput(event) {
    const input = event.target;
    const value = input.value.trim();
    const errorMsgId = input.id + '_error';

    // Remove any previous error
    const errorElem = document.getElementById(errorMsgId);
    if (errorElem) errorElem.remove();

    if (value === '') {
      this._deactivateRequestButton();
      // Show error message
      this._showTitleValidationError(input, errorMsgId);
    } else {
      this._checkRows();
      input.classList.remove('is-invalid');
    }
  }

  // Pickup change handler
  handlePickupChange() {
    this._checkRows();
  }

  // Checkbox change handler
  handleCheckboxChange(event) {
    const checkbox = event.target;
    const row = checkbox.closest('tr');

    if (row) {
      row.classList.toggle('selected', checkbox.checked);
    }

    this._checkRows();
  }

  // DataTable initialization
  initializeDataTable() {
    const tableElements = document.querySelectorAll('.tablesorter');
    tableElements.forEach((table) => {
      // Check if DataTable is available (jQuery DataTables)
      if (window.$ && window.$.fn.DataTable) {
        window.$(table).DataTable({
          language: {
            search: 'Search by Enumeration',
          },
          ordering: false,
        });
      }
    });
  }

  // Bind events
  bindEvents() {
    // Delivery mode radios
    const deliveryModeRadios = document.querySelectorAll(
      'input[type=radio][name^="requestable[][delivery_mode"]'
    );
    deliveryModeRadios.forEach((radio) => {
      radio.addEventListener('change', (event) =>
        this._handleDeliveryModeChange(event)
      );
    });

    // EDD article title inputs
    const eddTitleInputs = document.querySelectorAll(
      'input[type=text][id^="requestable__edd_art_title_"]'
    );
    eddTitleInputs.forEach((input) => {
      input.addEventListener('input', (event) =>
        this._handleEddTitleInput(event)
      );
    });

    // Pickup selects
    const pickupSelects = document.querySelectorAll(
      'select[name^="requestable[][pick_up"]'
    );
    pickupSelects.forEach((select) => {
      select.addEventListener('change', () => this.handlePickupChange());
    });

    // Table checkboxes
    const tableCheckboxes = document.querySelectorAll(
      '.table input[type=checkbox]'
    );
    tableCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener('change', (event) =>
        this.handleCheckboxChange(event)
      );
    });
  }
}

// Initialize RequestManager when DOM is ready
if (typeof document !== 'undefined') {
  document.addEventListener('DOMContentLoaded', () => {
    new RequestManager();
  });
}

// Make classes available for testing
if (
  typeof globalThis !== 'undefined' &&
  (typeof process !== 'undefined' || typeof window === 'undefined')
) {
  globalThis.RequestManager = RequestManager;
  globalThis.CollapseManager = CollapseManager;
}
