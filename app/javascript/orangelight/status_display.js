export default class StatusDisplay {
  setAvailableStatus(element) {
    element.text('Available').addClass('green strong');
    return element;
  }

  setOnSiteAccessStatus(element) {
    element.text('On-site access').addClass('green strong');
    return element;
  }

  setUnavailableStatus(element) {
    element.text('Unavailable').addClass('red strong');
    return element;
  }

  setRequestStatus(element) {
    element.text('Request').addClass('gray strong');
    return element;
  }

  setAskStaffStatus(element) {
    element.text('Ask Staff').addClass('gray strong');
    return element;
  }
}
