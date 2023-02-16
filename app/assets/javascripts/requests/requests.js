// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    function isEmail(email) {
      var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
      return regex.test(email);
    }

    $( "form#logins" ).submit(function( event ) {
      if ( !isEmail($( "#request_email" ).val()) ) {
        event.preventDefault();
        $( "#request_email" ).css("background-color","#f2dede");
        $( "span.error-email").css("color", "red");
        $( "span.error-email").text("Please supply a valid email address.");
      } else {
        $( "#request_email" ).css("background-color","#ffffff");
        $( "span.error-email").text("");
      }
      if ($.trim($('#request_user_name').val()) == "")
      {
        event.preventDefault();
        $( "#request_user_name" ).css("background-color","#f2dede");
        $( "span.error-user_name").css("color", "red");
        $( "span.error-user_name").text("Please supply your full name.");
      } else {
        $( "#request_user_name" ).css("background-color","#ffffff");
        $( "span.error-user_name").text("");
      }
    });

    $( "#no_netid").click(function( event ) {
      event.preventDefault();
      $( "#no_netid").hide();
      $( "#other_user_account_info").show();
    });

    $('#no_netid').keydown(function (e) {
      var keyCode = e.keyCode || e.which;

      if (keyCode == 13) {
        $( "#no_netid" ).trigger( "click" );
        return false;
      }
    });

    $( "#go_back").click(function( event ) {
      event.preventDefault();
      $( "#no_netid").show();
      $( "#other_user_account_info").hide();
    });

    // Enhance the Bootstrap collapse utility to toggle hide/show for other options
    $('input[type=radio][name^="requestable[][delivery_mode"]').on('change', function() {
        // collapse others
        $("input[name='" + this.name + "']").each(function( index ) {
          var target = $(this).attr('data-target');
          $(target).collapse('hide');
        });
        // open target
        var target = $(this).attr('data-target');
        $(target).collapse('show');

        checkAllRequestable();
    });

    $('input[type=checkbox][id^="requestable_selected"').on('change', function() {
      checkAllRequestable();
    });

    $('input[type=text][id^="requestable_user_supplied_enum_"').on('input', function() {
      checkAllRequestable();
    });

    function requestable(changed) {
      var parent = $(changed).closest('[id^="request_"]');
      var selected = parent.find('input[type=checkbox][id^="requestable_selected"').is(':checked');
      var delivery_mode = false;
      var radios = parent.find('input[type=radio][name^="requestable[][delivery_mode"]');
      if (radios.length === 0) {
        delivery_mode = true;
      } else {
        radios.each(function() {
          if ($(this).is(':checked')) {
            delivery_mode = true;
          }
        });
      }
      var volume_text = parent.find('input[type=text][id^="requestable_user_supplied_enum_"');
      var user_supplied = true;
      if (volume_text.length > 0 && volume_text.val().length === 0) {
        user_supplied = false;
      }
      if (selected && delivery_mode && user_supplied) {
        $('#request-submit-button').prop('disabled', false);
      }
    };

    function checkAllRequestable() {
      $('#request-submit-button').prop('disabled', true);
      $(".delivery--options").each(function() {
        requestable(this);
      });
    };

    checkAllRequestable();

    jQuery(function() {
      return $(".tablesorter").DataTable({
        language: {
          search: "Search by Enumeration"
        },
        ordering: false
      });
    });

    $('.table input[type=checkbox]').on('change', function() {
      $(this).closest('tr').toggleClass('selected', $(this).is(':checked'));
      requestable(this);
    });
  

});
