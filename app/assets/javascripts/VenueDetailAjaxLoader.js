/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var VenueDetailAjaxLoader = function(di) {
    this.di = di;
}; // end func

VenueDetailAjaxLoader.prototype = {

    load: function() {
        var that = this;
        that.di.loader.show();
        var url = window.location.pathname.toString().replace('/detail/', '/lazy-detail/');
        if ( window.location.search ) {
            url += window.location.search.toString();
        } // end if
        $.get(url, function(html){
            $('#detail-results-lazy').replaceWith(html);
            that.init();
            that.di.loader.hide();
        });
    }, // end method

    init: function() {
        var that = this;
        that.di.venueDetail = new VenueDetail(that.di);
        that.di.venueDetailLazyLoader = new DetailLazyLoader(that.di);
    }, // end method

}; // end prototype
