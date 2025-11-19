export default class StatusDisplay {
  setAvailableStatus(element) {
    element.textContent = 'Available';
    element.classList.add('green', 'strong');
    return element;
  }

  setSomeAvailableStatus(element) {
    element.textContent = 'Some Available';
    element.classList.add('green', 'strong');
    return element;
  }

  setOnSiteAccessStatus(element) {
    element.textContent = 'On-site access';
    element.classList.add('green', 'strong');
    return element;
  }

  setUnavailableStatus(element) {
    element.textContent = 'Unavailable';
    element.classList.add('red', 'strong');
    return element;
  }

  setRequestStatus(element) {
    element.textContent = 'Request';
    element.classList.add('gray', 'strong');
    return element;
  }

  setAskStaffStatus(element) {
    element.textContent = 'Ask Staff';
    element.classList.add('gray', 'strong');
    return element;
  }

  setUndeterminedStatus(element) {
    element.textContent = 'Undetermined';
    element.classList.add('gray', 'strong');
    return element;
  }

  setLoadingStatus(element) {
    element.textContent = 'Loading...';
    element.classList.add('gray', 'strong');
    return element;
  }
}
