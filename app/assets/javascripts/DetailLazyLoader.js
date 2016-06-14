/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var DetailLazyLoader = function(di) {
    this.di = di;
    this._data = this.di.venueDetail.getData();
    this._init();
}; // end func

DetailLazyLoader.prototype = {

    _init: function() {
        this._lazyLoadMeta();
        this._lazyLoadGeometry();
        this._lazyLoadAddress();
        this._lazyLoadTagLinks();
        this._lazyLoadDistance();
    }, // end method

    _lazyLoadMeta: function() {
      var that = this;
      var title = that._data.name + ' | Navihub';
      var desc = that._data.name + ' | ' + that._data.address;
      $('title').text(title);
      $('meta[name="description"]').attr('content', desc);
      $('meta[name="keywords"]').attr('content', desc);
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
                    var label = $(this).text();
                    var searchData = search.defaults;
                    searchData.term = label;
                    if ( that.di.locator.getRequestLocation() !== null ) {
                        searchData.loc = that.di.locator.getRequestLocation();
                    } // end if
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

                var loc;
                if ( that.di.locator.getRequestLocation() !== null ) {
                    loc = that.di.locator.getRequestLocation();
                } else {
                    loc = that.di.locator.getLocation();
                } // end if

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
                        cache: false,
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
