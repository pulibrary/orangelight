jQuery ->
  window.availability_updater = new AvailabilityUpdater
class AvailabilityUpdater
  constructor: ->
    this.request_availability()
  availability_url: "https://bibdata.princeton.edu/availability"
  id = ''
  available_statuses = ['Not charged', 'On shelf']
  returned_statuses = ['In transit discharged', 'Discharged']
  in_process_statuses = ['In process']
  checked_out_statuses = ['Charged', 'Renewed', 'Overdue', 'On hold',
    'In transit', 'In transit on hold', 'At bindery',
    'Remote storage request', 'Hold request', 'Recall request']
  missing_statuses = ['Missing', 'Lost--library applied',
    'Lost--system applied', 'Claims returned', 'Withdrawn']
  available_labels = ['Available', 'Returned', 'In process', 'Requestable',
    'On shelf', 'All items available']
  unavailable_labels = ['Checked out', 'Missing']
  request_availability: ->
    if $(".documents-list").length > 0
      ids = this.record_ids().toArray()
      params = $.param({ids: ids})
      url = "#{@availability_url}?#{params}"
      $.getJSON(url, this.process_records)
    else if $("*[data-availability-record='true']").length > 0
      id = window.location.pathname.split('/')[2]
      url = "#{@availability_url}?id=#{id}"
      $.getJSON(url, this.process_single)
  process_records: (records) =>
    for record_id, holding_records of records
      this.apply_record(record_id, holding_records)
  process_single: (holding_records) =>
    for holding_id, availability_info of holding_records
      availability_element = $("*[data-availability-record='true'][data-record-id='#{id}'][data-holding-id='#{holding_id}'] .availability-icon")
      if availability_info['on_reserve']
        location = $("*[data-location='true'][data-holding-id='#{holding_id}']")
        location.text(availability_info['on_reserve'])
        availability_element.after("<div class=\"copy-number\">Copy number: #{availability_info['copy_number']}</div>")
      this.get_issues(holding_id) if $(".journal-current-issues").length > 0
      if availability_info['more_items'] and availability_info['status'] != "Limited"
        this.apply_record_icon(availability_element, "All items available")
        this.get_more_items(holding_id)
      else
        this.apply_record_icon(availability_element, availability_info['status'])
  apply_record: (record_id, holding_records) ->
    for holding_id, availability_info of holding_records
      if availability_info['on_reserve']
        location = $("*[data-location='true'][data-record-id='#{record_id}'][data-holding-id='#{holding_id}']")
        location.text(availability_info['on_reserve'])
      this.record_needs_more_info(record_id) if availability_info['more_items']
      availability_element = $("*[data-availability-record='true'][data-record-id='#{record_id}'][data-holding-id='#{holding_id}'] .availability-icon")
      this.apply_record_icon(availability_element, availability_info['status'])
    true
  get_more_items: (holding_id) ->
    url = "#{@availability_url}?mfhd=#{holding_id}"
    req = $.getJSON url
    element = $("*[data-availability-record='true'][data-holding-id='#{holding_id}']")
    req.success (data) ->
      ul = "<ul class=\"item-status\">"
      for key, item of data
        if item['status'] != "Not Charged"
          li = "<li>#{item['enum']}: #{title_case(item['status'])}</li>"
          ul = ul + li
          span = $("*[data-holding-id='#{holding_id}'] .availability-icon")
          txt = "Some items not available"
          span.text(txt)
          span.attr("title", "Availability: " + txt)
          span.attr("data-original-title", "Availability: " + txt)
          span.removeClass("label-success")
          span.addClass("label-default")
      ul = ul + "</ul>"
      element.append(ul)
  get_issues: (holding_id) ->
    url = "#{@availability_url}?mfhd_serial=#{holding_id}"
    req = $.getJSON url
    element = $("*[data-journal='true'][data-holding-id='#{holding_id}']")
    req.success (data) ->
      if data.length > 1
        element.prepend("<div class=\"holding-label\">Current issues: <span class=\"pull-right trigger\">More</span></div>")
      else if data != ''
        element.prepend("<div class=\"holding-label\">Current issues:</div>")
      for key, issue of data
        li = $("<li>#{issue}</li>")
        element.append(li)
  record_needs_more_info: (record_id) ->
    element = $("*[data-record-id='#{record_id}'] .more-info")
    element.addClass("label label-default")
    element.text("View record for full availability")
    element.attr('title', "Click on the record for full availability info")
  apply_record_icon: (availability_element, status) ->
    status = title_case(status)
    availability_element.addClass("label")
    label = switch
      when status in available_statuses then 'Available'
      when status in returned_statuses then 'Returned'
      when status in in_process_statuses then 'In process'
      when status in checked_out_statuses then 'Checked out'
      when status in missing_statuses then 'Missing'
      when status == 'Limited' then 'On-site access'
      else status
    availability_element.text(label)
    if label in unavailable_labels
      availability_element.addClass("label-danger")
    else if label in available_labels
      availability_element.addClass("label-success")
    else if label == 'On-site access'
      availability_element.addClass("label-warning")
    else if label == 'Online'
      availability_element.addClass("label-primary")
    else
      availability_element.addClass("label-default")
    availability_element.attr('title', "Availability: #{title_case(status)}")
    availability_element.attr('data-original-title', "Availability: #{title_case(status)}")
    availability_element.attr('data-toggle', 'tooltip')
  record_ids: ->
    $("*[data-availability-record='true'][data-record-id]").map((_, x) -> $(x).attr("data-record-id"))
  title_case = (str) ->
    str[0].toUpperCase() + str[1..str.length - 1].toLowerCase()
