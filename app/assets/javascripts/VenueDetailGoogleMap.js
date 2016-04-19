/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
 * @author PN @since 2014-10-07
 */

/*
 *
 * @param {Object} center { latidude: float, longitude: float }
 * @param {String} canvas
 * @param {Number} zoom
 * @returns {VenueDetailGoogleMap}
 */
var VenueDetailGoogleMap = function(di, center, canvas, zoom, callback) {
    this.di = di;
    this.center = center;
    this.canvas = canvas;
    this.zoom = zoom;
    this.callback = callback || function(){};
    this.map = null;

    this._$wrapper = $("#" + this.canvas);

    if (this._$wrapper.length) {
        this._init();
    } // end if
}; // end func

VenueDetailGoogleMap.prototype = {

    /**
     * @return {void}
     * @access private
     */
    _init: function() {
        var that = this;
        that.di.detailGoogleMap = that;
        if (!VenueDetailGoogleMap.googleApiLoaded) {
            var apiUrl = that.di.config.googleMapsLibraryUrl;
            var apiCallback = 'DI.detailGoogleMap.initGoogleMap';
            that.di.scriptLoader.load(apiUrl, apiCallback, function() {
                VenueDetailGoogleMap.googleApiLoaded = true;
            });
        } else {
            that.initGoogleMap();
        } // end if
    },
    /**
     * @returns {void}
     * @access public
     * @author PN @since 2014-10-07
     * @uses global DI
     */
    initGoogleMap: function() {
        // TODO: event listener nefunguje !
        //google.maps.event.addDomListener(window, 'load', function() {
        var mapCanvas = document.getElementById(DI.detailGoogleMap.canvas);
        if ( mapCanvas ) {
          var mapOptions = {
              center: new google.maps.LatLng(DI.detailGoogleMap.center.latitude, DI.detailGoogleMap.center.longitude),
              zoom: DI.detailGoogleMap.zoom,
              mapTypeId: google.maps.MapTypeId.ROADMAP,
              streetViewControl: true,
              scrollwheel: false
          };
          DI.detailGoogleMap.map = new google.maps.Map(mapCanvas, mapOptions);
          DI.detailGoogleMap.callback();
        } else {
            console.log("VenueDetailGoogleMap.js loaded from external script");
          // VenueDetailGoogleMap.js loaded from external script
        } // end if
        //});
    }, // end method
    addMarker: function() {

    },
    addRoute: function(origin, destination, mode) {
        var that = this;
        mode = (mode in ['DRIVING', 'WALKING', 'BICYCLING', 'TRANSIT'] ? mode : 'WALKING');
        var directionsService = new google.maps.DirectionsService();
        directionsDisplay = new google.maps.DirectionsRenderer();
        directionsDisplay.setMap(that.map);
        var request = {
            origin: new google.maps.LatLng(origin.latitude, origin.longitude),
            destination: new google.maps.LatLng(destination.latitude, destination.longitude),
            travelMode: google.maps.TravelMode[mode]
        };
        directionsService.route(request, function(response, status) {
            if (status == google.maps.DirectionsStatus.OK) {
                directionsDisplay.setDirections(response);
            } // end if
        });
        //
    },

}; // end prototype
