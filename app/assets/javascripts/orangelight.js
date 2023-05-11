//= require 'jquery'

$(function() {
    //link highlighting of hierarchy
    $(".search-subject, .search-name-title, .search-title").hover(
        function() {
            $(this).prevAll().addClass("field-hierarchy");
        },
        function() {
            $(this).prevAll().removeClass("field-hierarchy");
        }
    );

    $('.chosen-select').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    //tooltip for everything else
    $("#main-container").tooltip({
        selector: "[data-toggle='tooltip']",
        placement: "bottom",
        container: "body",
        trigger: "hover"
    });

    // availability toggle journal current issues
    $("#availability").on("click", ".trigger", function(event) {
        event.preventDefault();
        $(this).siblings(".journal-current-issues").children().toggleClass("all-issues");
        $(this).text(function(i, toggle) {
            return toggle === "More" ? "Less" : "More";
        });

    });

    //Select all items in specific account table to be checked or unchecked
    $("body").on("change", "[id^='select-all']", function (e) {
        if (this.checked) {
            $(this).closest("table").find("td input:checkbox").each(function(index) {
                $(this).prop("checked", true);
                $(this).closest("tr").toggleClass("info", this.checked);
            });
        } else {
            $(this).closest("table").find("td input:checkbox").each(function(index) {
                $(this).prop("checked", false);
                $(this).closest("tr").toggleClass("info", this.checked);
            });
        }
    });

    //Add active class to tr if selected
    $("body").on("change", "td input:checkbox", function(e) {
        $(this).closest("tr").toggleClass("info", this.checked);
    });

    // Auto dismiss alert-info and alert-success
    setTimeout(function() {
      $(".flash_messages .alert-info, .flash_messages .alert-success").fadeOut('slow', function(){
        $(".flash_messages .alert-info, .flash_messages .alert-success").remove();
      });
    }, 5000);

    $('#search_field').on('change', function(e){
        $('#q').attr('placeholder', $(this).find(':selected').data('placeholder'));
    });

    // Back to top button appears on scroll
    $(window).scroll(function(){
        if ($(this).scrollTop() > 100) {
            $('.back-to-top').fadeIn();
        } else {
            $('.back-to-top').fadeOut();
        }
    });

    $('.back-to-top').click(function(){
        $('html, body').animate({scrollTop : 0},800);
        return false;
    });

    $('.document-thumbnail').click(function(e){
        var target = $('#viewer-container');
        if( target.length ) {
            e.preventDefault();
            $('html, body').stop().animate({
                scrollTop: target.offset().top
            }, 800);
        }
    });

    $('.facet-select').one('click', function (e) {
        if ($('#q').val()) {
            var query = encodeURIComponent($('#q').val())
            var queryDict = {};
            this.href.substr(1).split("&").forEach(function(item) {
                queryDict[item.split("=")[0]] = item.split("=")[1]
            });
            if (query != queryDict['q']) {
                if (queryDict['q'] == null) {
                    this.href = this.href + '&q=' + query;
                } else {
                    this.href = this.href.replace('&q='+queryDict['q'], '&q='+query);
                }
            }
            if ($('#search_field').val() != queryDict['search_field']) {
                if (queryDict['search_field'] == null) {
                    this.href = this.href + '&search_field=' + $("#search_field").val();
                } else {
                    this.href = this.href.replace('&search_field='+queryDict['search_field'],
                                                  '&search_field='+$('#search_field').val());
                }
            }
        }
    });
    $('.clickable-row').on("click",function(){
      window.location = $(this).data('href');
    });

    $('#unauthenticated-library-account-link').on("click",function(){
        // Update the page with the id of the user once they have authenticated.
        // Since we don't know how long it will take the user to authenticate via CAS
        // we set up a timer to check every couple of seconds.
        var getUserIdTimer = setInterval(function(){
            $.getJSON("/account/user-id", function(data) {
                if (data.user_id !== null) {
                    clearInterval(getUserIdTimer);
                    $("button.dropdown-toggle.btn-account").text(data.user_id);
                }
            });
        }, 2000);
        return true;
      });

});
