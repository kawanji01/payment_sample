document.addEventListener("turbolinks:load", function() {
    $('.move-to-catalog-request').click(function() {
        var catalogRequest = $('#catalog-request').offset().top;
        $('html, body').animate({scrollTop:catalogRequest});
    });

});