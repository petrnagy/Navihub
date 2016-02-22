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
        var $spinner = $('#detail-results .result-geometry .fa-spinner');
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
        var $spinner = $('#detail-results .result-address .fa-spinner');
        if ( $spinner.length && that._data.geometry ) {
            that.di.locator.doLazyReverseGeocoding(that._data.geometry, $spinner, that._data.name);
        } // end if
    }, // end method

    _lazyLoadTagLinks: function() {
        var that = this;
        var interval = setInterval(function() {
            if ( that.di.locator.getLocation() !== null ) {
                clearInterval(interval);

                var $set = $('#detail-results .result-tags .label');
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
        var interval = setInterval(function(){
            if ( that.di.locator.getLocation() !== null ) {
                clearInterval(interval);

                var loc = that.di.locator.getLocation();
                var origin = loc.lat.toString() + ',' + loc.lng.toString();
                var destination = null;
                if ( typeof that._data.geometry === 'object' ) {
                    destination = that._data.geometry.lat.toString() + ',' + that._data.geometry.lng.toString();
                } else if ( typeof that._data.address === 'string' && that._data.address.length > 1 ) {
                    destination = that._data.address;
                } // end if

                if ( destination !== null ) {
                    $.ajax({
                        url: '/lazy/distance-matrix',
                        data: { origins: [origin], destinations: [destination] },
                        cache: true,
                        success: function(response) {
                            var $distance = $('#detail-results .distance-wrapper .result-distance');
                            var $walkingDistance = $('#detail-results .distance-wrapper .result-walking-distance');
                            var $carDistance = $('#detail-results .distance-wrapper .result-car-distance');
                            $.each([$distance, $walkingDistance, $carDistance], function(){
                                $(this).find('p.detail-window-p').remove();
                                $(this).find('i.fa-spinner').remove();
                            });
                            $distance.append(response.data.distance);
                            $walkingDistance.append(response.data.foot_distance);
                            $carDistance.append(response.data.car_distance);
                        }, // end func
                        error: function(response) {
                            $('#detail-results .distance-wrapper i.fa-spinner').remove();
                        }, // end func
                    }); // end ajax
                } // end if
            } // end if
        }, 1000);
    }, // end method

}; // end prototype
