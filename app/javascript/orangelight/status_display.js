export default class StatusDisplay {
  setAvailableStatus(element) {
    if (element) {
      element.textContent = 'Available';
      element.classList.add('green', 'strong');
    }
    return element;
  }

  setSomeAvailableStatus(element) {
    if (element) {
      element.textContent = 'Some Available';
      element.classList.add('green', 'strong');
    }
    return element;
  }

  setOnSiteAccessStatus(element) {
    if (element) {
      element.textContent = 'On-site access';
      element.classList.add('green', 'strong');
    }
    return element;
  }

  setUnavailableStatus(element) {
    if (element) {
      element.textContent = 'Unavailable';
      element.classList.add('red', 'strong');
    }
    return element;
  }

  setRequestStatus(element) {
    if (element) {
      element.textContent = 'Request';
      element.classList.add('gray', 'strong');
    }
    return element;
  }

  setAskStaffStatus(element) {
    if (element) {
      element.textContent = 'Ask Staff';
      element.classList.add('gray', 'strong');
    }
    return element;
  }

  setUndeterminedStatus(element) {
    if (element) {
      element.textContent = 'Undetermined';
      element.classList.add('gray', 'strong');
    }
    return element;
  }

  setLoadingStatus(element) {
    if (element) {
      element.textContent = 'Loading...';
      element.classList.add('gray', 'strong');
    }
    return element;
  }
}
