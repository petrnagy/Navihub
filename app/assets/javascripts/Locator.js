/**
 * @author PN @since 2014-09-28
 */
var Locator = function() {
    this._data = {browser: null, web: null};
    this._envelope = {
        lat: null, lng: null, country: null, country_short: null,
        city: null, city2: null, street1: null, street2: null, origin: null,
    };
    this._sent = {browser: false, web: false};
    this._interval = null;
    this._init();
} // end func

Locator.prototype = {
    _init: function() {
        var that = this;
        that._loadFromBrowser();
        that._loadFromWeb();
        that._interval = setInterval(function() {
            if (that._sent.browser) {
                clearInterval(that._interval);
            } else {
                if (!that._sent.browser && that._data.browser) {
                    that._send(that._data.browser);
                    that._sent.browser = true;
                } else if (!that._sent.web && that._data.web && !that._sent.browser) {
                    that._send(that._data.web);
                    that._sent.web = true;
                } // end if
            } // end if
        }, 1000);
    },
    _loadFromBrowser: function() {
        var that = this;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(response) {
                try {
                    var data = {};
                    $.extend(data, that._envelope);
                    data.lat = response.coords.latitude;
                    data.lng = response.coords.longitude;
                    data.origin = 'browser';
                    that._data.browser = data;
                } catch (e) {
                    that._data.browser = false;
                } // end try-catch
            }, function() {
                that._data.browser = false;
            });
        } else {
            that._data.browser = false;
        }
    },
    _loadFromWeb: function() {
        var that = this;
        $.get("http://ipinfo.io", function(response) {
            if (typeof response === 'object') {
                try {
                    var data = {};
                    $.extend(data, that._envelope);
                    var coords = response.loc.split(',');
                    data.lat = coords[0];
                    data.lng = coords[1];
                    data.origin = 'web';
                    that._data.web = data;
                } catch (e) {
                    that._data.web = false;
                } // end try-catch
            } // end if
        }, "jsonp");
    },
    _send: function(data) {
        var that = this;
        var data = data;
        var cache = that._getFromCache();
        if (!cache || cache.lat != data.lat || cache.lng != data.lng) {
            data.set = 1;
            $.ajax({
                url: '/settings/location',
                data: data,
                success: function(){
                    that._saveToCache(data);
                },
            });
        } // end if
    },
    _getFromCache: function() {
        return null;
        return $.cookie('_navihub_loc_cache');
    },
    _saveToCache: function(data) {
        return;
        $.cookie('_navihub_loc_cache', data);
    },
    getLocation: function() {
        var that = this;
        return that._data.browser ? that._data.browser : that._data.web;
    },
} // end prototype