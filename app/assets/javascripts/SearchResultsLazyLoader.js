var SearchResultsLazyLoader = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResultsLazyLoader.prototype = {

    _init: function() {
        this._initSearchResultsLazyLoading();
    }, // end method

    _initSearchResultsLazyLoading: function() {
        var that = this;
        $(window).scroll(function() { that.lazyLoad(); });
        $(window).resize(function() { that.lazyLoad(); });
        $(window).on("orientationchange", function() { that.lazyLoad(); });
    }, // end method

    lazyLoad: function() {
        var that = this;
        that._lazyLoadSearchResultsImages();
        that._lazyLoadSearchResultsGeometries();
        that._lazyLoadSearchResultsAddresses();
        that._lazyLoadSearchResultsTagLinks();
        that._lazyInitEllipsis();
        that._lazyLoadSearchResultsOpenDetail();
        that._lazyLoadMapPopups();
        that._lazyLoadRoutePopups();
        that._lazyLoadSocialSharingUrls();
    }, // end method

    _lazyLoadSearchResultsImages: function() {
        var that = this;
        var $set = $('#yield #search-results .map-wrapper img[lazysrc]:in-viewport');
        $set.each(function(){
            var lazySrc = '/lazy/static-map-img?src=' + encodeURIComponent($(this).attr('lazysrc'));
            var $img = $(this);
            $img.attr('src', lazySrc);
            $img.removeAttr('lazysrc');
        });
    }, // end method

    _lazyLoadSearchResultsGeometries: function() {
        var that = this;
        var $set = $('#yield #search-results .result-geometry .fa-spinner:in-viewport').not('.pending');
        $set.each(function(){
            $(this).addClass('pending');
            var data = that.di.searchResult.getData($(this));
            if ( data && data.address.length ) {
                that.di.locator.doLazyGeocoding(data.address, $(this), function(){
                    that._lazyLoadMapPopups();
                    that._lazyLoadRoutePopups();
                });
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsAddresses: function() {
        var that = this;
        var $set = $('#yield #search-results .result-address .fa-spinner:in-viewport').not('.pending');
        $set.each(function() {
            $(this).addClass('pending');
            var data = that.di.searchResult.getData($(this));
            if ( data && data.geometry ) {
                that.di.locator.doLazyReverseGeocoding(data.geometry, $(this), null, function(){
                    that._lazyInitEllipsis();
                    that._lazyLoadMapPopups();
                    that._lazyLoadRoutePopups();
                });
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsTagLinks: function() {
        var that = this;
        that.di.locator.addHook(function(){
            var $set = $('#yield #search-results .result-tags .label:in-viewport').not('.done');
            $set.each(function(){
                $(this).addClass('done');
                var label = $(this).text().replace('-', ' ');
                var searchData = {};
                if (that.di.controller === 'search') {
                    searchData = that.di.search.getValues();
                } else if (that.di.controller === 'favorites') {
                    searchData = that.di.search.defaults;
                }  // end if-else-if
                searchData.term = label;
                var url = that.di.search.buildUrl(searchData);
                $(this).parent().attr('href', url);
            });
        });
    }, // end method

    _lazyInitEllipsis: function() {
        var that = this;
        var $set = $('#yield #search-results .result-address:in-viewport').not('.dotted').filter(function(){
            return ( $(this).find('i.unknown-data').length === 0 );
        });
        $set.addClass('dotted').dotdotdot();
    }, // end method

    _lazyLoadSearchResultsOpenDetail: function() {
        var that = this;
        that.di.locator.addHook(function() {
            var $set = $('#search-results .details-wrapper:in-viewport ul.dropdown-menu .list-open-detail, #search-results .result-box:in-viewport .list-open-detail-eye')
            .filter(function(){
                return ( $(this).attr('href') === '#' );
            });
            $set.each(function(){
                var data = that.di.searchResult.getData($(this));
                if ( data ) {
                    var url = window.location.origin + Detail.prototype.buildDetailUrl(data, that);
                    $(this).attr('href', url);
                    var $h2 = $(this).closest('.result-box').find('h2').first();
                    $h2.find('a').attr('href', url);
                    // wrap name with
                    // var $a = $('<a></a>');
                    // var name = $h2.html();
                    // $a.attr('href', url);
                    // $a.html(name);
                    // $h2.replaceWith($a);
                } // end if
            });
        });
    }, // end method

    _lazyLoadMapPopups: function() {
        var that = this;
        var $set = $('#search-results .result-box:in-viewport a.list-open-in-maps').filter(function(){
            if ( $(this).attr('href') === '#' ) {
                var geometryMissing = ($(this).closest('result-box').find('.result-geometry .fa-spinner').length > 0);
                var addressMissing = ($(this).closest('result-box').find('.result-address .fa-spinner').length > 0);
                if ( ! geometryMissing || ! addressMissing ) {
                    return true;
                } // end if
            } // end if
            return false;
        });
        $set.each(function(){
            var data = that.di.searchResult.getData($(this));
            if ( data ) {
                var url = 'http://maps.google.com/?';
                var popupUrl = 'https://www.google.com/maps/embed/v1/place?q=';
                if ( data.geometry.lat !== null && data.geometry.lng !== null ) {
                    popupUrl += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    url += 'll=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                } else {
                    popupUrl += data.address;
                    url += 'q=' + data.address;
                } // end if
                popupUrl += '&key=' + that.di.config.googleApiPublicKey;
                url += '&z=17';
                $(this).attr('href', url);
                $(this).attr('popup-href', popupUrl);
            } // end if
        });
    }, // end method

    _lazyLoadRoutePopups: function() {
        var that = this;
        that.di.locator.addHook(function(){
            var loc = that.di.locator.getLocation();

            var $set = $('#search-results .result-box:in-viewport a.list-plan-a-route').filter(function() {
                if ( $(this).attr('href') === '#' ) {
                    var geometryMissing = ($(this).closest('result-box').find('.result-geometry .fa-spinner').length > 0);
                    var addressMissing = ($(this).closest('result-box').find('.result-address .fa-spinner').length > 0);
                    if ( geometryMissing && addressMissing ) {
                        return false;
                    } else {
                        return true;
                    } // end if-else
                } // end if
                return false;
            });
            $set.each(function() {
                var data = that.di.searchResult.getData($(this));
                if ( data ) {
                    var url = 'https://maps.google.com?';
                    var popupUrl = 'https://www.google.com/maps/embed/v1/directions?destination=';
                    if ( data.geometry.lat !== null && data.geometry.lng !== null ) {
                        popupUrl += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                        url += 'daddr=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        popupUrl += encodeURIComponent(data.address);
                        url += 'daddr=' + data.address;
                    } // end if
                    popupUrl += '&origin=' + loc.lat.toString() + ',' + loc.lng.toString();
                    url += '&saddr=' + loc.lat.toString() + ',' + loc.lng.toString();
                    popupUrl += '&key=' + that.di.config.googleApiPublicKey;
                    $(this).attr('href', url);
                    $(this).attr('popup-href', popupUrl);

                } // end if
            });
        });
    }, // end method

    _lazyLoadSocialSharingUrls: function() {
        var that = this;
        that.di.locator.addHook(function(){
            var key = '%%URL%%';
            var loc = that.di.locator.getLocation();

            var $set = $('#search-results .result-box:in-viewport .list-share-btn').filter(function() {
                return ( $(this).attr('href').indexOf(key) >= 0 );
            });

            $set.each(function(i, el){
                var $el = $(el);
                var data = that.di.searchResult.getData($el);
                var url = that.di.searchResult.getDetailUrl(data);
                if ( url ) {
                    $el.attr('href', $el.attr('href').replace(key, url));
                } // end if
            });
        });
    }, // end method

}; // end prototype
