// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    function isEmail(email) {
        const regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return regex.test(email);
    }

    $("form#logins").submit(function(event) {
        if (!isEmail($("#request_email").val())) {
            event.preventDefault();
            $("#request_email").css("background-color","#f2dede");
            $("span.error-email").css("color", "red");
            $("span.error-email").text("Please supply a valid email address.");
        } else {
            $("#request_email").css("background-color","#ffffff");
            $("span.error-email").text("");
        }
        if ($.trim($('#request_user_name').val()) == "")
        {
            event.preventDefault();
            $("#request_user_name").css("background-color","#f2dede");
            $("span.error-user_name").css("color", "red");
            $("span.error-user_name").text("Please supply your full name.");
        } else {
            $("#request_user_name").css("background-color","#ffffff");
            $("span.error-user_name").text("");
        }
    });

    $("#no_netid").click(function(event) {
        event.preventDefault();
        $("#no_netid").hide();
        $("#other_user_account_info").show();
    });

    $('#no_netid').keydown(function (e) {
        const keyCode = e.keyCode || e.which;

        if (keyCode == 13) {
            $("#no_netid").trigger("click");
            return false;
        }
    });

    $("#go_back").click(function(event) {
        event.preventDefault();
        $("#no_netid").show();
        $("#other_user_account_info").hide();
    });

    function activateRequestButton () {
        $('#request-submit-button').prop('disabled', false);
    }

    function deactivateRequestButton () {
        $('#request-submit-button').prop('disabled', true);
    }

    deactivateRequestButton();
    
    function requestable(changed) {
        const parent = $(changed).closest('[id^="request_"]');
        const selected = parent.find('input[type=checkbox][id^="requestable_selected"').is(':checked');
        const radios = parent.find('input[type=radio][name^="requestable[][delivery_mode"]');
        let delivery_mode = false;
        let delivery_location = false;

        if (radios.length === 0) {
            delivery_mode = true;
        } else {
            radios.each(function() {
                if ($(this).is(':checked')) {
                    if (this.dataset['target'].startsWith('#fields-eed')) {
                        delivery_mode = true;
                        delivery_location = true;
                    } else {
                        delivery_mode = true;
                    }
                }
            });
        }

        const requestable_pickups = parent.find('select[name^="requestable[][pick_up"] option');
        
        // If there is only one pickup delivery location the length is 0
        if (requestable_pickups.length === 0) {
            delivery_location = true;
        } else {
        // When there are more than one pickup delivery locations
            requestable_pickups.each(function() {
                if ($(this).is(':selected') && $(this).val() !== '') {
                    delivery_location = true;
                }
            });
        }

        if (selected && delivery_mode && delivery_location) {
            activateRequestButton();
        } else {
            deactivateRequestButton();
        }
    }

    // Enhance the Bootstrap collapse utility to toggle hide/show for other options
    $('input[type=radio][name^="requestable[][delivery_mode"]').on('change', function() {
        // collapse others
        $("input[name='" + this.name + "']").each(function() {
            const target = $(this).attr('data-target');
            $(target).collapse('hide');
        });
        // open target
        const target = $(this).attr('data-target');
        $(target).collapse('show');
        requestable(this);
    });

    $('input[type=checkbox][id^="requestable_selected"').on('change', function() {
        if ($(this).val()) {
            activateRequestButton();
        } else {
            deactivateRequestButton();
        }
    });

    $('input[type=text][id^="requestable__edd_art_title_"').on('input', function() {
        if ($(this).val() === "") {
            $('#request-submit-button').prop('disabled', true);
        } else {
            requestable(this);
        }
    });

    $('select[name^="requestable[][pick_up"]').on('change', function() {
        requestable(this);
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
        requestable(this);
    });

});
