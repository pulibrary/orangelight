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
  constructor() {
    this.submitButton = document.getElementById('request-submit-button');
    this.init();
  }

  init() {
    this.checkRows();
    this.bindEvents();
    this.initializeDataTable();
  }

  // Request button enable/disable logic
  activateRequestButton() {
    if (this.submitButton) {
      this.submitButton.disabled = false;
    }
  }

  deactivateRequestButton() {
    if (this.submitButton) {
      this.submitButton.disabled = true;
    }
  }

  // Row validation logic
  checkRows() {
    const rows = document.querySelectorAll('tr[id^=request_]');
    let anyValidRows = false;

    rows.forEach((row) => {
      if (this.requestable(row)) {
        anyValidRows = true;
      }
    });

    if (anyValidRows) {
      if (this.electronicDeliveryTitleProvided()) {
        this.activateRequestButton();
      } else {
        this.deactivateRequestButton();
      }
    } else {
      this.deactivateRequestButton();
    }
  }

  electronicDeliveryTitleProvided() {
    const titleInput = document.querySelector(
      'input[type=text][id^="requestable__edd_art"]'
    );
    return titleInput && titleInput.value.trim() !== '';
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
  handleDeliveryModeChange(event) {
    const target = event.target;

    // Use CollapseManager to handle all collapse logic
    CollapseManager.handleDeliveryModeChange(target);

    // Re-validate the form after the change
    this.checkRows();
  }

  // EDD title input handler
  handleEddTitleInput(event) {
    if (event.target.value === '') {
      this.deactivateRequestButton();
    } else {
      this.checkRows();
    }
  }

  // Pickup change handler
  handlePickupChange() {
    this.checkRows();
  }

  // Checkbox change handler
  handleCheckboxChange(event) {
    const checkbox = event.target;
    const row = checkbox.closest('tr');

    if (row) {
      row.classList.toggle('selected', checkbox.checked);
    }

    this.checkRows();
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
        this.handleDeliveryModeChange(event)
      );
    });

    // EDD article title inputs
    const eddTitleInputs = document.querySelectorAll(
      'input[type=text][id^="requestable__edd_art_title_"]'
    );
    eddTitleInputs.forEach((input) => {
      input.addEventListener('input', (event) =>
        this.handleEddTitleInput(event)
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
