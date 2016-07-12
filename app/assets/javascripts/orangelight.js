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

    $('.chosen-select').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
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

    $('.facet_select').one('click', function (e) {
        if ($('#q').val()) {
            var queryDict = {};
            this.href.substr(1).split("&").forEach(function(item) {
                queryDict[item.split("=")[0]] = item.split("=")[1]
            });
            if ($('#q').val() != queryDict['q']) {
                if (queryDict['q'] == null) {
                    this.href = this.href + '&q=' + $('#q').val();
                } else {
                    this.href = this.href.replace('&q='+queryDict['q'], '&q='+$('#q').val());
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
});
