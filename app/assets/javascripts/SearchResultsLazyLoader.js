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
                that.di.locator.doLazyGeocoding(data.address, $(this));
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
                });
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsTagLinks: function() {
        var that = this;
        var interval = setInterval(function(){
            if ( that.di.locator.getLocation() !== null ) {
                clearInterval(interval);

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
            } // end if
        }, 1000);
    }, // end method

    _lazyInitEllipsis: function() {
        var that = this;
        var $set = $('#yield #search-results .result-address:in-viewport').filter(function(){
            return ( $(this).find('i.unknown-data').length === 0 );
        });
        $set.dotdotdot();
    }, // end method

}; // end prototype
