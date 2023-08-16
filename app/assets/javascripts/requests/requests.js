// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
    function isEmail(email) {
        const regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return regex.test(email);
    }

    $("form#logins").on("submit", function(event) {
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

    $("#no_netid").on("click", function(event) {
        event.preventDefault();
        $("#no_netid").hide();
        $("#other_user_account_info").show();
    });

    $('#no_netid').on("keydown", function (e) {
        const keyCode = e.keyCode || e.which;

        if (keyCode == 13) {
            $("#no_netid").trigger("click");
            return false;
        }
    });

    $("#go_back").on("click",function(event) {
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

    function radioOfRadioBtns (radios) {
        const radio_checked = document.querySelectorAll('input[type=radio][name^="requestable[][delivery_mode"]:checked');

        let mode = false;
        if (radios && radio_checked.length > 0) {
            for (const radio of radio_checked) {
                if (radio && radio.dataset['target'].startsWith('#fields-eed')) {
                    mode = true;
                    // when it's an edd it should have delivery location true;
                } else {
                    mode = true;
                }
            }
        }
        return mode;
    }

    function deliveryLocation () {
        const requestable_pickups_options = document.querySelectorAll('select[name^="requestable[][pick_up"] option');

        function requestablePickups () {
            // If there is only one pickup delivery location the length is 0
            let pickup;
            if (requestable_pickups_options.length === 0) {
                pickup = true;
            } else {
            // When there are more than one pickup delivery locations
                for (const pickupOption of requestable_pickups_options) {
                    if (pickupOption.selected == true && pickupOption.value !== '') {
                        pickup = true;
                    }
                }
            }
            return pickup;
        }
        return requestablePickups;
    }

    function deliveryMode () {
        const radios = document.querySelectorAll('input[type=radio][name^="requestable[][delivery_mode"]');

        function radioButtons () {
            let mode;

            if (radios.length === 0) {
                const deLocation = deliveryLocation();
                mode = deLocation();
            } else {
                mode = radioOfRadioBtns(radios);
            }
            return mode;
        }
        return radioButtons;
    }

    const deLocation_ref = deliveryLocation();
    const deMode_ref = deliveryMode();

    function requestable(el) {
        const parent = $(el).closest('[id^="request_"]');
        let selected = parent.find('input[type=checkbox][id^="requestable_selected"').is(':checked');
        let deLocation = deLocation_ref();
        let deMode = deMode_ref();

        const radio_checked = parent.find('input[type=radio][name^="requestable[][delivery_mode"]:checked');
        const radio = parent.find('input[type=radio][name^="requestable[][delivery_mode"]');
        const requestable_pickups_options = parent.find('select[name^="requestable[][pick_up"] option');
        if (selected) {
            selected = true;
        } else {
            selected = false;
        }

        // Special case for edd form. Needs to set delivery location so that the request button is active.
        if (radio_checked.length === 1 && radio_checked[0].dataset['target'].startsWith('#fields-eed')) {
            deLocation = true;
        }
        if (selected && requestable_pickups_options.length === 0 && radio.length === 0) {
            deMode = true;
        }
        if (selected && deMode && deLocation) {
            activateRequestButton();
        } else {
            deactivateRequestButton();
        }
    }

    (function () {
        const checkbox_nodelist = document.querySelectorAll('[id^="requestable_selected"]');
        let selected;

        if (checkbox_nodelist.length === 1) {
            const radio_checked = document.querySelectorAll('input[type=radio][name^="requestable[][delivery_mode"]:checked');
            selected = true;
            let deLocation = deLocation_ref();
            const deMode = deMode_ref();

            // Special case for edd form. Needs to set delivery location so that the request button is active.
            if (radio_checked.length === 1 && radio_checked[0].dataset['target'].startsWith('#fields-eed')) {
                deLocation = true;
            }
            if (selected && deMode && deLocation) {
                activateRequestButton();
            } else {
                deactivateRequestButton();
            }
        } else {
            deactivateRequestButton();
            requestable();
        }
    })();

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
