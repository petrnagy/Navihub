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
        $(window).on("orientationchange",function() { that.lazyLoad(); });
    }, // end method

    lazyLoad: function() {
        var that = this;
        that._lazyLoadSearchResultsImages();
        that._lazyLoadSearchResultsGeometries();
        that._lazyLoadSearchResultsAddresses();
        that._lazyLoadSearchResultsTagLinks();
        that._lazyLoadSearchResultsDistances();
    }, // end method

    _lazyLoadSearchResultsImages: function() {
        var that = this;
        $set = $('#yield #search-results .map-wrapper img[lazysrc]:in-viewport');
        $set.each(function(){
            var lazySrc = '/lazy/static-map-img?src=' + encodeURIComponent($(this).attr('lazysrc'));
            var $img = $(this);
            $img.attr('src', lazySrc);
            $img.removeAttr('lazysrc');
        });
    }, // end method

    _lazyLoadSearchResultsGeometries: function() {
        var that = this;
        $set = $('#yield #search-results .result-geometry .fa-spinner:in-viewport').not('.pending');
        $set.each(function(){
            $(this).addClass('pending');
            var data = that.di.searchResult.getData($(this));
            if ( data && data.address.length ) {
                that.di.locator.doLazyGeocoding(data.address, $(this));
                // TODO: nejaky delay
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsAddresses: function() {
        var that = this;
        $set = $('#yield #search-results .result-address .fa-spinner:in-viewport').not('.pending');
        $set.each(function() {
            $(this).addClass('pending');
            var data = that.di.searchResult.getData($(this));
            if ( data && data.geometry ) {
                that.di.locator.doLazyReverseGeocoding(data.geometry, $(this));
                // TODO: nejaky delay
            } // end if
        });
    }, // end method

    _lazyLoadSearchResultsTagLinks: function() {
        var that = this;
        $set = $('#yield #search-results .result-tags .label:in-viewport').not('.done');
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
    }, // end method

    _lazyLoadSearchResultsDistances: function() {
      var that = this;
      console.log("_lazyLoadSearchResultsDistances - not implemented");
    }, // end method

}; // end prototype
