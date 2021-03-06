/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
 * @author PN @since 2014-09-28
 * @param {String} address
 */
GoogleGeocode = function(address) {
    this._apiUrl = 'http://maps.google.com/maps/api/geocode/json?language=en&address=';
    this._address = address;
    this._init();
} // end func

GoogleGeocode.prototype = {

    _init: function() {

    },

    /**
     * @param {Function} callback
     * @returns {void}
     */
    load: function(callback) {
        $.ajax({
            url: this._apiUrl + encodeURIComponent(this._address),
            success: function(data) {
                try {
                    var coords = data.results[0].geometry.location;
                    callback(coords);
                } catch (e) {
                    callback(null);
                }
                //callback(coords);
            },
        });
    },
}
