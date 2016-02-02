//= require 'jquery'

$( document ).ready(function() {
    //link highlighting of subject heirarchy
    $(".search-subject").hover(
        function() {
            $(this).prevAll().addClass("subject-heirarchy");
        }, function() {
            $(this).prevAll().removeClass("subject-heirarchy");
        }
    );

    //tooltip for subject heirarchy
    $(".document").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "bottom",
        container: "body",
        trigger: "hover"
    });

    //tooltip for call number browse
    $(".holding-call-number").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "bottom",
        container: "body",
        trigger: "hover"
    });

    //tooltip for availability-icon
    $("[data-record-id]").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "left",
        container: "body",
        trigger: "hover"
    });

    //tooltip for subject heirarchy
    $(".facet-values").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "right",
        container: "body",
        trigger: "hover"
    });

    //tooltip for stack map
    $(".library-location").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "right",
        container: "body",
        trigger: "hover"
    });

    //tooltip for disabled request
    $(".location-services").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "right",
        container: "body",
        trigger: "hover"
    });

    //tooltip for rss/atom feed
    $("#sortAndPerPage").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "bottom",
        container: "body",
        trigger: "hover"
    });

    ///////////////////////////////////////////
    // temporarily disable blacklight folders//
    //on change, submit form / add to folder //
    // $('#folder_id').change(function() {   //
    //     this.form.submit();               //
    // });                                   //
    ///////////////////////////////////////////
});
