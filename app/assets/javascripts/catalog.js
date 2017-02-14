// Function that sets a cookie and its expiration date
function cookieTerms(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

// Function to find a cookie if it exists, if not returns empty string
function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return name;//c.substring(name.length,c.length);
    }
    return "";
}

// Function that checks if the "terms" cookie exists
// If it doesn't, it displays the alert box for the cookie usage
function checkCookie() {
    var cookie = getCookie("terms");
    if (cookie == ""){
        var cookieButtonElem = document.getElementById("cookie-button");
        if (cookieButtonElem) {
            cookieButtonElem.style.display = "block";
        }
    }
}


$(document).ready(function () {

    // Logic to sort the facet modal on alphabetical order by default: When the open event starts for the modal,
    // the 'Alfabetisk' button is clicked
    if ($('body').is('.blacklight-catalog-index')) { // Do this only in the index page
        $('#ajax-modal').on('show.bs.modal', function (e) { // When the modal open event starts
            if (!$('#ajax-modal').is(':visible')) { // If the modal is hidden
                $('.sort_change.az.btn.btn-default').click(); // Click the button
            }
        });
    }
    $("ul.missing").find("a").text("Ukendt");
});
