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
    $('input[type=radio][name^="requestable[][delivery_mode"]').change(function() {
        // collapse others
        $("input[name='" + this.name + "']").each(function( index ) {
          var target = $(this).attr('data-target');
          $(target).collapse('hide');
        });
        // open target
        var target = $(this).attr('data-target');
        $(target).collapse('show');

    });

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
    });
  

});
