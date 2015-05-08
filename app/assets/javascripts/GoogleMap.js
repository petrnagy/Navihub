/**
 * @author PN @since 2014-10-07
 */

/*
 *
 * @param {Object} center { latidude: float, longitude: float }
 * @param {String} canvas
 * @param {Number} zoom
 * @returns {GoogleMap}
 */
var GoogleMap = function(di, center, canvas, zoom, callback, googleMapApiSrc) {
    this.di = di;
    this.center = center;
    this.canvas = canvas;
    this.zoom = zoom;
    this.callback = callback || function(){};
    this.map = null;
    this._loadedScripts = [];
    this.storageKey = 'loaded_google_maps';

    this._$wrapper = $("#" + this.canvas);
    this._googleMapApiSrc = googleMapApiSrc || 'https://maps.googleapis.com/maps/api/js?v=3&callback=DI.detailGoogleMap.initGoogleMap';

    if (this._$wrapper.length) {
        this._init();
    } // end if
}; // end func

GoogleMap.prototype = {

    /**
     * @return {void}
     * @access private
     */
    _init: function() {
        var that = this;
        that.di.detailGoogleMap = that;
        if (!GoogleMap.googleApiLoaded) {
            that.loadScripts(function() {
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
              streetViewControl: false
          };
          DI.detailGoogleMap.map = new google.maps.Map(mapCanvas, mapOptions);
          DI.detailGoogleMap.callback();
        } else {
          // GoogleMap.js loaded from external script
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
    /**
     * @param {function} callback
     * @returns {void}
     * @access public
     * @author PN @since 2014-10-07
     */
    loadScripts: function(callback, di) {
        var that = this;

        if ( ! di && ! that.di ) {
            throw new Error("This method needs DI container instance");
        } // end if

        that.di = di || that.di;

        callback = (typeof callback === 'function' ? callback : function() {});
        var storageKey = that.storageKey;
        var loadedScripts = that.di.turbolinksStorage.get(storageKey);
        loadedScripts = ( null === loadedScripts ? [] : loadedScripts );

        if ( loadedScripts.indexOf(that._googleMapApiSrc) >= 0 ) {
            callback();
        } else {
            loadedScripts.push(that._googleMapApiSrc);
            that.di.turbolinksStorage.set(storageKey, loadedScripts);
            $.getScript(that._googleMapApiSrc, callback);
        } // end if
    }, // end method


}; // end prototype
