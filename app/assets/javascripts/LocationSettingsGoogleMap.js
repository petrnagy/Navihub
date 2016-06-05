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
* @author PN @since 2015-12-11
*/
var LocationSettingsGoogleMap = function(di, center, canvas, zoom, callback) {
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

LocationSettingsGoogleMap.prototype = {

    /**
    * @return {void}
    * @access private
    * @author PN @since 2015-12-11
    */
    _init: function() {
        var that = this;
        that.di.locationSettingsGoogleMap = that;
        if (!LocationSettingsGoogleMap.googleApiLoaded) {

            var apiUrl = that.di.config.googleMapsLibraryUrl;
            var apiCallback = 'DI.locationSettingsGoogleMap.initGoogleMap';
            that.di.scriptLoader.load(apiUrl, apiCallback, function() {
                LocationSettingsGoogleMap.googleApiLoaded = true;
            });
        } else {
            that.initGoogleMap();
        } // end if
    },

    /**
    * @returns {void}
    * @access public
    * @author PN @since 2015-12-11
    * @uses global DI
    */
    initGoogleMap: function() {
        var mapCanvas = document.getElementById(DI.locationSettingsGoogleMap.canvas);
        if ( mapCanvas ) {
            var mapOptions = {
                center: new google.maps.LatLng(DI.locationSettingsGoogleMap.center.latitude, DI.locationSettingsGoogleMap.center.longitude),
                zoom: DI.locationSettingsGoogleMap.zoom,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                streetViewControl: false,
                disableDefaultUI: true,
                scrollwheel: false,
                draggable: false,
                disableDoubleClickZoom: true
            };
            DI.locationSettingsGoogleMap.map = new google.maps.Map(mapCanvas, mapOptions);
            google.maps.event.addListenerOnce(DI.locationSettingsGoogleMap.map, 'idle', function(){
                DI.locationSettingsGoogleMap.callback();
            });
        } else {
            throw new Error('Canvas not found');
        } // end if
    }, // end method

}; // end prototype
