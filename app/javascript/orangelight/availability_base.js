import StatusDisplay from './status_display.js';

export default class AvailabilityBase {
  constructor() {
    this.bibdata_base_url = document.body.getAttribute('data-bibdata-base-url');
    this.availability_url = `${this.bibdata_base_url}/availability`;
    this.status_display = new StatusDisplay();
  }

  apply_availability_label(availability_element, availability_info) {
    if (availability_element) {
      availability_element.classList.add('lux-text-style');
    }
    const { status_label, location } = availability_info;
    const specialStatusLocations = [
      'marquand$stacks',
      'marquand$pj',
      'marquand$ref',
      'marquand$ph',
      'marquand$fesrf',
      'RES_SHARE$IN_RS_REQ',
    ];

    if (availability_element) {
      availability_element.textContent = status_label;
    }

    if (status_label.toLowerCase() === 'unavailable') {
      this.handle_availability_status(
        location,
        availability_element,
        specialStatusLocations
      );
    } else if (status_label.toLowerCase() === 'available') {
      this.status_display.setAvailableStatus(availability_element);
    } else if (status_label.toLowerCase() === 'some available') {
      this.status_display.setSomeAvailableStatus(availability_element);
    } else if (status_label.toLowerCase() === 'on-site access') {
      this.handleOnSiteAccessStatus(availability_element, status_label);
    } else {
      if (availability_element) {
        availability_element.classList.add('gray', 'strong');
      }
    }
    return availability_element;
  }

  handleOnSiteAccessStatus(availability_element) {
    throw new Error('handleOnSiteAccessStatus must be implemented by subclass');
  }

  handle_availability_status(
    location,
    availability_element,
    specialStatusLocations
  ) {
    throw new Error(
      'handle_availability_status must be implemented by subclass'
    );
  }
}
