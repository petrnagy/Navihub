var DetailLazyLoader = function(di) {
    this.di = di;
    this._data = this.di.venueDetail.getData();
    this._init();
}; // end func

DetailLazyLoader.prototype = {

    _init: function() {
        this._lazyLoadGeometry();
        this._lazyLoadAddress();
        this._lazyLoadTagLinks();
        this._lazyLoadDistance();
    }, // end method

    _lazyLoadGeometry: function() {
        var that = this;
        $spinner = $('#detail-results .result-geometry .fa-spinner');
        if ( $spinner.length && that._data.address ) {
            that.di.locator.doLazyGeocoding(that._data.address, $spinner);
        } // end if
    }, // end method

    _lazyLoadAddress: function() {
        var that = this;
        $spinner = $('#detail-results .result-address .fa-spinner');
        if ( $spinner.length && that._data.geometry ) {
            that.di.locator.doLazyReverseGeocoding(that._data.geometry, $spinner);
        } // end if
    }, // end method

    _lazyLoadTagLinks: function() {
        var that = this;
        $set = $('#detail-results .result-tags .label');
        var search = new Search(null, that.di);
        $set.each(function(){
            var label = $(this).text().replace('-', ' ');
            var searchData = search.defaults;
            searchData.term = label;
            var url = search.buildUrl(searchData);
            $(this).parent().attr('href', url);
        });
    }, // end method

    _lazyLoadDistance: function() {
        var that = this;
        console.log("_lazyLoadDistance - not implemented");
    }, // end method

}; // end prototype
