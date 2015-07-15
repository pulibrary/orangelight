//= require 'jquery'

$( document ).ready(function() {
    $('li .search-subject').hover(
        function() {
            $(this).prevAll().addClass("subject-heirarchy");
        }, function() {
            $(this).prevAll().removeClass("subject-heirarchy");
        }
    );
});