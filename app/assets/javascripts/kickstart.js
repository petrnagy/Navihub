/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

function kickstart_homepage(di) {
    if ($("#search-input").length) {
        di.input = new Input(21, di);
        di.hpSearchBox = new HomepageSearchBox(di);
    } // end if
} // end func

function kickstart_detail(di) {
    if ($("#detail-results-lazy").length) {
        di.venueDetailAjaxLoader = new VenueDetailAjaxLoader(di);
        di.venueDetailAjaxLoader.load();
    } else if ($("#detail-results").length) {
        di.venueDetailAjaxLoader = new VenueDetailAjaxLoader(di);
        di.venueDetailAjaxLoader.init();
    } // end if
} // end func

function kickstart_permalink(di) {
    if ( 'show' === di.action ) {
        kickstart_detail(di);
    } // end if
} // end func

function kickstart_search(di) {
    if ( $('#search-results-lazy').length ) {
        di.searchAjaxLoader = new SearchAjaxLoader(di);
        di.searchAjaxLoader.load();
    } else if ( $("#search-form").length ) {
        di.searchAjaxLoader = new SearchAjaxLoader(di);
        di.searchAjaxLoader.init();
    } // end if
} // end func

function kickstart_favorites(di){
    if ($(".result-box").length) {
        di.search = new Search(null, di);
        di.searchResult = new SearchResult(di);
        di.lazyLoader = new SearchResultsLazyLoader(di);
        di.lazyLoader.lazyLoad();
        di.lazyLoader.initEllipsis();
    } // end if
} // end func

function kickstart_settings(di) {
    if ($("form#settings-location").length) {
        di.locationSettingsMap = new LocationSettingsMap(di, di.config.mockLocation);
        di.locationSettingsMap.init();
    } // end if
} // end func
