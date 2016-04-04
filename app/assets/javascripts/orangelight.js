//= require 'jquery'

$(document).ready(function() {
    //link highlighting of subject heirarchy
    $(".search-subject").hover(
        function() {
            $(this).prevAll().addClass("subject-heirarchy");
        },
        function() {
            $(this).prevAll().removeClass("subject-heirarchy");
        }
    );

    //tooltip for facet remove button
    $(".facet-values").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "right",
        container: "body",
        trigger: "hover"
    });


    //tooltip for everything else
    $("#content").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "bottom",
        container: "body",
        trigger: "hover"
    });

    // availability toggle journal current issues
    $("#availability").on("click", ".trigger", function(event) {
        event.preventDefault();
        $(this).parent().siblings().toggleClass("all-issues");
        $(this).text(function(i, toggle) {
            return toggle === "More" ? "Less" : "More";
        });

    });

    ///////////////////////////////////////////
    // temporarily disable blacklight folders//
    //on change, submit form / add to folder //
    // $('#folder_id').change(function() {   //
    //     this.form.submit();               //
    // });                                   //
    ///////////////////////////////////////////

    //Select all items for renew in accoun
    $("body").on('change', '#renew-choices', function (e) {
        if ($(this).val() == "select-all-renew") {
            $('.account--charged_items').find('td input:checkbox').each(function(index) {
                $(this).prop('checked', true);
            });
        }
    });
});
