//= require 'jquery'

$( document ).ready(function() {
    $('li .subject-level').hover(
        function() {
            $(this).prevAll().addClass("subject-heirarchy");
        }, function() {
            $(this).prevAll().removeClass("subject-heirarchy");
        }
    );
});