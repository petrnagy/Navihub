
function kickstart_homepage(di) {
    if ($("#search-input").length) {
        di.input = new Input(21, di);
        di.hpSearchBox = new HomepageSearchBox(di);
    } // end if
} // end func

function kickstart_detail(di) {
    if ($("#detail-results").length) {
        di.venueDetail = new VenueDetail(di);
    } // end if
} // end func

function kickstart_permalinks(di) {
    if ( 'show' === di.action ) {
        kickstart_detail(di);
    } // end if
} // end func

function kickstart_search(di) {
    if ($("#search-form").length) {
        di.search = new Search(21, di); // 21 results per page
        di.btn = new NextButton(di);
        di.searchResult = new SearchResult(di);
        di.lazyLoader = new SearchResultsLazyLoader(di);
        di.lazyLoader.lazyLoad();
    } // end if
} // end func

function kickstart_favorites(di){
    if ($(".result-box").length) {
        //di.search = new Search(21, di); // 21 results per page
        //di.btn = new NextButton(di);
        di.searchResult = new SearchResult(di);
        di.lazyLoader = new SearchResultsLazyLoader(di);
        di.lazyLoader.lazyLoad();
    } // end if
} // end func

function kickstart_settings(di) {
    if ($("form#settings-location").length) {
        // FIXME: pokud existuje lokace, tak nastavit !!!
        di.locationSettingsMap = new LocationSettingsMap(di, di.config.mockLocation);
        di.locationSettingsMap.init();
    } // end if
} // end func
