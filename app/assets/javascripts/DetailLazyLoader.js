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
            that.di.locator.doLazyGeocoding(that._data.address, $spinner, function(data){
                that.di.venueDetail.setVenueLocation({
                    lat: data.data.lat,
                    lng: data.data.lng
                });
            });
        } // end if
    }, // end method

    _lazyLoadAddress: function() {
        var that = this;
        $spinner = $('#detail-results .result-address .fa-spinner');
        if ( $spinner.length && that._data.geometry ) {
            that.di.locator.doLazyReverseGeocoding(that._data.geometry, $spinner, that._data.name);
        } // end if
    }, // end method

    _lazyLoadTagLinks: function() {
        var that = this;
        var interval = setInterval(function() {
            if ( that.di.locator.getLocation() !== null ) {
                clearInterval(interval);

                $set = $('#detail-results .result-tags .label');
                var search = new Search(null, that.di);
                $set.each(function(){
                    var label = $(this).text().replace('-', ' ');
                    var searchData = search.defaults;
                    searchData.term = label;
                    var url = search.buildUrl(searchData);
                    $(this).parent().attr('href', url);
                });
            } // end if
        }, 1000);
    }, // end method

    _lazyLoadDistance: function() {
        var that = this;
        console.log("_lazyLoadDistance - not implemented");
    }, // end method

}; // end prototype
