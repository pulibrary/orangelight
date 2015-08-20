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
        container: "body"
    });

    //on change, submit form / add to folder
    $('#folder_id').change(function() {
        this.form.submit();
    });
});