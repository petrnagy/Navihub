/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var SearchResultsLazyLoader = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResultsLazyLoader.prototype = {

    _init: function() {
        this._initSearchResultsLazyLoading();
        this._initPageMeta();
    }, // end method

    _initSearchResultsLazyLoading: function() {
        var that = this;
        //$(window).scroll(function() { that.lazyLoad(); });
        $(window).resize(function() { that.lazyLoad(); });
        $(window).on("orientationchange", function() { that.lazyLoad(); });
        $(window).scroll(function() {
            clearTimeout($.data(this, 'scrollTimer'));
            $.data(this, 'scrollTimer', setTimeout(function() {
                that.lazyLoad();
            }, 250));
        });
    }, // end method

    lazyLoad: function() {
        var that = this;
        that._lazyLoadSearchResultsImages();
        //that._lazyLoadSearchResultsGeometries();
        that._lazyLoadSearchResultsAddresses();
        that._lazyLoadSearchResultsTagLinks();
        //that._lazyInitEllipsis();
        //that._lazyInitTooltips();
        that._lazyLoadSearchResultsOpenDetail();
        that._lazyLoadMapPopups();
        that._lazyLoadRoutePopups();
        that._lazyLoadSocialSharingUrls();
        that._lazyLoadWebsiteRedirects();
    }, // end method

    _lazyLoadSearchResultsImages: function() {
        var that = this;
        var $set = $('#yield #search-results .map-wrapper img[lazysrc]:in-viewport').filter(function(){
            return ($(this).closest('.result-box').find('.result-geometry .fa-spinner').length === 0);
        });
        $set.each(function(){
            var lazySrc = '/lazy/static-map-img?src=' + encodeURIComponent($(this).attr('lazysrc'));
            var $img = $(this);
            $img.attr('src', lazySrc);
            $img.removeAttr('lazysrc');
        });
    }, // end method

    /**
     * @deprecated
     */
    _lazyLoadSearchResultsGeometries: function() {
        var that = this;
        var $set = $('#yield #search-results .result-geometry .fa-spinner:in-viewport').not('.pending');
        $set.each(function(){
            $(this).addClass('pending');
            var data = that.di.searchResult.getData($(this));
            if ( data && data.address.length ) {
                var $parent = $(this).parent();
                that.di.locator.doLazyGeocoding(data.address, $(this), function(data){
                    if ( data.data.lat && data.data.lng ) {
                        var $img = $parent.closest('.result-box').find('.map-wrapper img');
                        if ( $img.length ) {
                            var lazysrc = $img.attr('lazysrc');
                            if ( lazysrc.length ) {
                                var ll = data.data.lat.toString() + ',' + data.data.lng.toString();
                                var matches = lazysrc.match(/center=(.*?)&/);
                                console.log(matches);
                                if ( matches.length && matches[1] && matches[1] !== ll ) {
                                    var newsrc = lazysrc.replaceAll(matches[1], ll);
                                    console.log(newsrc);
                                    $img.attr('lazysrc', newsrc);
                                } // end if
                            } // end if
                        } // end if
                    } // end if
                    $parent.addClass( $parent.attr('data-class') );
                    that._lazyLoadMapPopups();
                    that._lazyLoadRoutePopups();
                    that._lazyLoadSearchResultsImages();
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
                    that._lazyLoadSearchResultsImages();
                });
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsTagLinks: function() {
        var that = this;
        that.di.locator.addHook(function(){
            var $set = $('#yield #search-results .labels-wrapper .label:in-viewport').not('.done');
            $set.each(function(){
                $(this).addClass('done');
                var label = $(this).text();
                var searchData = {};
                if (that.di.controller === 'search') {
                    searchData = that.di.search.getValues();
                } else if (that.di.controller === 'favorites') {
                    searchData = that.di.search.defaults;
                }  // end if-else-if
                searchData.term = label;
                if ( that.di.locator.getRequestLocation() !== null ) {
                    searchData.loc = that.di.locator.getRequestLocation();
                } // end if
                var url = that.di.search.buildUrl(searchData);
                $(this).parent().attr('href', url);
            });
        });
    }, // end method

    /**
     * @deprecated
     */
    _lazyInitEllipsis: function() {
        var that = this;
        var $set = $('#yield #search-results .result-address:in-viewport').not('.dotted').filter(function(){
            return ( $(this).find('i.unknown-data').length === 0 );
        });

        //$set.addClass('dotted');
        that.di.ellipsis.do($set);
    }, // end method

    /**
     * @deprecated
     */
    _lazyInitTooltips: function() {
        var that = this;
        if ( ! that.di.browser.isMobileDevice() ) {
            var $set = $('#yield #search-results .result-box .autotooltip:in-viewport').not('.has-tooltip');

            $set.addClass('has-tooltip').tooltipsy({offset: [0, 10]});
        } // end if
    }, // end method

    _lazyLoadSearchResultsOpenDetail: function() {
        var that = this;
        that.di.locator.addHook(function() {
            var $set = $('#search-results .result-box:in-viewport .list-open-detail')
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
            var hasGeo = data.geometry.lat !== null && data.geometry.lng !== null;
            if ( data ) {
                var url, popupUrl = 'https://www.google.com/maps/embed/v1/place?q=';
                if ( that.di.browser.isIos() ) {
                    if ( hasGeo ) {
                        url = 'http://maps.apple.com?ll=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'http://maps.apple.com?q=' + data.address;
                    } // end if
                } else if ( that.di.browser.isAndroid() ) {
                    if ( hasGeo ) {
                        url = 'http://maps.google.com?z=19&ll=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'http://maps.google.com?z=19&q=' + data.address;
                    } // end if
                } else if ( that.di.browser.isWindowsPhone() ) {
                    // TODO: was not tested
                    if ( hasGeo ) {
                        url = 'maps:' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'maps:' + data.address;
                    } // end if
                } else {
                    if ( hasGeo ) {
                        url = 'http://maps.google.com/?z=17&ll=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'http://maps.google.com/?z=17&q=' + data.address;
                    } // end if
                } // end if

                if ( hasGeo ) {
                    popupUrl += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                } else {
                    popupUrl += data.address;
                } // end if
                popupUrl += '&key=' + that.di.config.googleApiPublicKey;
                $(this).attr('href', url);
                $(this).attr('popup-href', popupUrl);
            } // end if
        });
    }, // end method

    _lazyLoadRoutePopups: function() {
        var that = this;

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
            var requestLoc = that.di.locator.getRequestLocation();
            // if ( requestLoc === null ) {
            //     requestLoc = that.di.locator.getLocation();
            // } // end if
            var origin = requestLoc.lat.toString() + ',' + requestLoc.lng.toString();
            var hasGeo = data.geometry.lat !== null && data.geometry.lng !== null;
            if ( data ) {
                var url, popupUrl = 'https://www.google.com/maps/embed/v1/directions?destination=';

                if ( that.di.browser.isIos() ) {
                    if ( hasGeo ) {
                        url = 'http://maps.apple.com?dirflg=d&saddr=' + origin + '&daddr=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'http://maps.apple.com?dirflg=d&saddr=' + origin + '&daddr=' + data.address;
                    } // end if
                } else if ( that.di.browser.isAndroid() ) {
                    if ( hasGeo ) {
                        url = 'http://maps.google.com?saddr=' + origin + '&daddr=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'http://maps.google.com?saddr=' + origin + '&daddr=' + data.address;
                    } // end if
                } else if ( that.di.browser.isWindowsPhone() ) {
                    // TODO: was not tested
                    if ( hasGeo ) {
                        url = 'maps:' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'maps:' + data.address;
                    } // end if
                } else {
                    if ( hasGeo ) {
                        url = 'https://maps.google.com?saddr=' + origin + '&daddr=' + data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                    } else {
                        url = 'https://maps.google.com?saddr=' + origin + '&daddr=' + data.address;
                    } // end if
                } // end if

                if ( hasGeo ) {
                    popupUrl += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
                } else {
                    popupUrl += encodeURIComponent(data.address);
                } // end if
                popupUrl += '&origin=' + origin;
                popupUrl += '&key=' + that.di.config.googleApiPublicKey;

                $(this).attr('href', url);
                $(this).attr('popup-href', popupUrl);

            } // end if
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

    _lazyLoadWebsiteRedirects: function() {
        var that = this;
        var $set = $('#search-results .result-box:in-viewport .list-visit-website[href="#"]');
        $set.each(function(i, el){
            var $el = $(el);
            var data = that.di.searchResult.getData($el);
            var url = that.di.searchResult.getWebsiteRedirectUrl(data);
            if ( url ) {
                $el.attr('href', url);
            } // end if
        });
    }, // end method

    _initPageMeta: function() {
        var that = this;
        $('title').text($('#search-results').attr('data-title'));
        $('meta[name="description"]').attr('content', $('#search-results').attr('data-desc'));
        $('meta[name="keywords"]').attr('content', $('#search-results').attr('data-keywords'));
    }, // end method

    /**
     * @deprecated
     */
    initEllipsis: function() {
        var that = this;
        /* run ellipsis lazyload manually, because we cannot detect css rendering finish point */
        for (var i = 1; i <= 30; i++) {
            setTimeout(function(){
                that._lazyInitEllipsis();
            }, i * 1000);
        } // end for
    }, // end method

}; // end prototype
