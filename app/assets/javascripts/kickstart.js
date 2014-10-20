
function kickstart_homepage(di) {
    if ($("#search-input").length) {
        di.input = new Input(21);
    } // end if
} // end func

function kickstart_detail(di) {
    if ($("#detail-results").length) {
        di.venueDetail = new VenueDetail(di);
    } // end if
} // end func

function kickstart_search(di) {
    if ($("#search-form").length) {
        di.search = new Search(21); // 21 results per page
        di.btn = new NextButton(di.search);
        $(document).delegate('.btn-detail', 'click', function(e) {
            e.preventDefault();
            DetailFactory.activate($(this), di);
            return false;
        });
    } // end if
} // end func