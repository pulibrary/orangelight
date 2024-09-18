// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function () {
  function isEmail(email) {
    const regex =
      /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
  }

  $('form#logins').on('submit', function (event) {
    if (!isEmail($('#request_email').val())) {
      event.preventDefault();
      $('#request_email').css('background-color', '#f2dede');
      $('span.error-email').css('color', 'red');
      $('span.error-email').text('Please supply a valid email address.');
    } else {
      $('#request_email').css('background-color', '#ffffff');
      $('span.error-email').text('');
    }
    if ($('#request_user_name').val().trim() == '') {
      event.preventDefault();
      $('#request_user_name').css('background-color', '#f2dede');
      $('span.error-user_name').css('color', 'red');
      $('span.error-user_name').text('Please supply your full name.');
    } else {
      $('#request_user_name').css('background-color', '#ffffff');
      $('span.error-user_name').text('');
    }
  });

  $('#no_netid').on('click', function (event) {
    event.preventDefault();
    $('#no_netid').hide();
    $('#other_user_account_info').show();
  });

  $('#no_netid').on('keydown', function (e) {
    const keyCode = e.keyCode || e.which;

    if (keyCode == 13) {
      $('#no_netid').trigger('click');
      return false;
    }
  });

  $('#go_back').on('click', function (event) {
    event.preventDefault();
    $('#no_netid').show();
    $('#other_user_account_info').hide();
  });

  function activateRequestButton() {
    $('#request-submit-button').prop('disabled', false);
  }

  function deactivateRequestButton() {
    $('#request-submit-button').prop('disabled', true);
  }

  deactivateRequestButton();

  function checkRows() {
    const rows = document.querySelectorAll('tr[id^=request_]');
    let anyValidRows = false;
    rows.forEach((row) => {
      if (requestable($(row))) {
        anyValidRows = true;
      }
    });

    if (anyValidRows) {
      activateRequestButton();
    } else {
      deactivateRequestButton();
    }
  }

  function requestable(parent) {
    const selected = parent
      .find('input[type=checkbox][id^="requestable_selected"')
      .is(':checked');

    return selected && deliveryMode(parent) && deliveryLocation(parent);
  }

  function deliveryLocation(parent) {
    const requestable_pickups = parent.find(
      'select[name^="requestable[][pick_up"] option'
    );
    let delivery_location = false;

    if (requestable_pickups.length === 0 || isEed(parent)) {
      delivery_location = true;
    } else {
      requestable_pickups.each(function () {
        if ($(this).is(':selected') && $(this).val() !== '') {
          delivery_location = true;
        }
      });
    }
    return delivery_location;
  }

  function deliveryMode(parent) {
    const radios = parent.find(
      'input[type=radio][name^="requestable[][delivery_mode"]'
    );
    let delivery_mode = false;

    if (radios.length === 0) {
      delivery_mode = true;
    } else {
      radios.each(function () {
        if ($(this).is(':checked')) {
          delivery_mode = true;
        }
      });
    }
    return delivery_mode;
  }

  function isEed(parent) {
    const radios = parent.find(
      'input[type=radio][name^="requestable[][delivery_mode"]'
    );
    let eedRequest = false;

    if (radios.length > 0) {
      radios.each(function () {
        if ($(this).is(':checked')) {
          eedRequest = this.dataset['target'].startsWith('#fields-eed');
        }
      });
    }
    return eedRequest;
  }

  // Enhance the Bootstrap collapse utility to toggle hide/show for other options
  $('input[type=radio][name^="requestable[][delivery_mode"]').on(
    'change',
    function () {
      // collapse others
      $("input[name='" + this.name + "']").each(function () {
        const target = $(this).attr('data-target');
        $(target).collapse('hide');
      });
      // open target
      const target = $(this).attr('data-target');
      $(target).collapse('show');
      checkRows(this);
    }
  );

  $('input[type=text][id^="requestable__edd_art_title_"').on(
    'input',
    function () {
      if ($(this).val() === '') {
        $('#request-submit-button').prop('disabled', true);
      } else {
        checkRows(this);
      }
    }
  );

  $('select[name^="requestable[][pick_up"]').on('change', function () {
    checkRows(this);
  });

  jQuery(function () {
    return $('.tablesorter').DataTable({
      language: {
        search: 'Search by Enumeration',
      },
      ordering: false,
    });
  });

  $('.table input[type=checkbox]').on('change', function () {
    $(this).closest('tr').toggleClass('selected', $(this).is(':checked'));
    checkRows(this);
  });
});
