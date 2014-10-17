/**
 * @author PN @since 2014-10-07
 */

// https://developers.google.com/maps/documentation/javascript/examples/directions-travel-modes

/*
 * 
 * @param {Object} center { latidude: float, longitude: float }
 * @param {String} canvas
 * @param {Number} zoom
 * @returns {GoogleMap}
 */
var GoogleMap = function(center, canvas, zoom, callback) {
    this.center = center;
    this.canvas = canvas;
    this.zoom = zoom;
    this.callback = callback || function(){};
    this.map = null;

    this._$wrapper = $("#" + this.canvas);
    this._googleMapApiSrc = 'https://maps.googleapis.com/maps/api/js?callback=detailGoogleMap.initGoogleMap&v=3';

    if (this._$wrapper.length) {
        this._init();
    } // end if
} // end func

GoogleMap.prototype = {
    /**
     * @return {void}
     * @access private
     */
    _init: function() {
        var that = this;
        detailGoogleMap = that;
        if (!GoogleMap.googleApiLoaded) {
            that._loadScripts(function() {
                GoogleMap.googleApiLoaded = true;
            });
        } else {
            that.initGoogleMap();
        } // end if
    },
    /**
     * @returns {void}
     * @access public
     * @author PN @since 2014-10-07
     * @uses global detailGoogleMap
     */
    initGoogleMap: function() {
        // TODO: event listener nefunguje !
        //google.maps.event.addDomListener(window, 'load', function() {
        var mapCanvas = document.getElementById(detailGoogleMap.canvas);
        var mapOptions = {
            center: new google.maps.LatLng(detailGoogleMap.center.latitude, detailGoogleMap.center.longitude),
            zoom: detailGoogleMap.zoom,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        detailGoogleMap.map = new google.maps.Map(mapCanvas, mapOptions);
        detailGoogleMap.callback();
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
    /**
     * @param {function} callback
     * @returns {void}
     * @access private
     * @author PN @since 2014-10-07
     */
    _loadScripts: function(callback) {
        var that = this;
        var callback = (typeof callback === 'function' ? callback : function() {
        });
        $.getScript(that._googleMapApiSrc, callback);
    }, // end method


} // end prototype