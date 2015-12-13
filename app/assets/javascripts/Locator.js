/**
* @author PN @since 2014-09-28
*/
var Locator = function(di) {
    this.di = di;
    this._locked = false;
    this._key = '<i class="fa fa-key" title="Address is locked. Click \'autodetect\' to unlock it."></i>&nbsp;';
    this._data = {browser: null, web: null};
    this._envelope = {
        lat: null, lng: null, country: null, country_short: null,
        city: null, city2: null, street1: null, street2: null, origin: null
    };
    this._sent = {browser: false, web: false};
    this._interval = null;
    this._saveCallback = null;
    this._didAutomaticReverseGeocoding = false;
    this._initAutodetectBtn();
}; // end func

Locator.prototype = {

    locate: function(manual) {
        var that = this;
        that._loadFromBrowser();
        that._loadFromWeb();
        that._interval = setInterval(function() {
            if (that._sent.browser) {
                clearInterval(that._interval);
            } else {
                if ( ! that._sent.browser && that._data.browser ) {
                    that._send(that._data.browser, manual);
                    that._sent.browser = true;
                } else if ( ! that._sent.web && that._data.web && ! that._sent.browser ) {
                    that._send(that._data.web, manual);
                    that._sent.web = true;
                } // end if
            } // end if
        }, 1000);
    },

    reset: function() {
        var that = this;
        that._sent = {browser: false, web: false};
        that._data = {browser: null, web: null};
        if ( that._interval ) {
            clearInterval(that._interval);
        } // end if
        that._interval = null;
    }, // end method

    /**
    * Manually sets location
    *
    * @param  {Object} location
    * @return {Boolean}
    * @access public
    */
    set: function(location) {
        var that = this;
        // mask custom location as browser location, thus it will have top priority
        location.origin = 'browser';
        location.lock = 1;
        that._data = {browser: location, web: null};
        if ( that._interval ) {
            clearInterval(that._interval);
        } // end if
        that._interval = null;
        that._send(that._data.browser, true, false, true);
        that._sent = {browser: true, web: true};
        if ( location.formatted.length ) {
            that.writeLoc(location.formatted);
        } // end if
    }, // end method

    _loadFromBrowser: function() {
        var that = this;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(response) {
                try {
                    var data = that.di.mixin.clone(that._envelope);
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
        } // end if
    },

    _loadFromWeb: function() {
        var that = this;
        $.get("http://ipinfo.io", function(response) {
            if (typeof response === 'object') {
                try {
                    var data = that.di.mixin.clone(that._envelope);
                    var coords = response.loc.split(',');
                    data.lat = coords[0];
                    data.lng = coords[1];
                    data.origin = 'web';
                    that._data.web = data;
                } catch (e) {
                    that._data.web = false;
                } // end try-catch
            } else {
                throw new Error("ipinfo.io response: object expected, got: " + (typeof response) );
            } // end if
        }, "jsonp");
    },

    _send: function(data, manual, write, lock) {
        var that = this;
        var cache = that._getFromCache();
        lock = ( lock ? true : false );
        if ( ! cache || cache.lat !== data.lat || cache.lng !== data.lng ) {
            data.set = 1;
            data.lock = ( lock ? 1 : 0 );
            $.ajax({
                url: '/settings/location',
                data: data,
                success: function(response) {
                    if ( write ) {
                        that.writeLoc(response.html);
                    } // end if
                    that._saveToCache(data);

                    if (lock) {
                        that.lock();
                    } else {
                        that.unlock();
                    } // end if-else

                    // load google maps api, do a reverse geocoding and save it as detailed location in local DB
                    if ( ! that._didAutomaticReverseGeocoding && ! that.isLocked() ) {
                        var apiUrl = that.di.config.googleMapsLibraryUrl;
                        var apiCallback = 'DI.locator._doReverseGeocoding';
                        that._didAutomaticReverseGeocoding = true;
                        that.di.scriptLoader.load(apiUrl, apiCallback);
                    } else if ( manual ) {
                        that.di.spinner.show();
                        that._doReverseGeocoding(that, lock);
                        that.flash();
                    } // end if // end if

                    if ( that._saveCallback ) {
                        that._saveCallback();
                    } // end if

                } // end func
            });
        } // end if
    },

    _getFromCache: function() {
        return;
        //return $.cookie('_navihub_loc_cache');
    },

    _saveToCache: function(data) {
        return;
        //$.cookie('_navihub_loc_cache', data);
    },

    getLocation: function() {
        var that = this;
        return that._data.browser ? that._data.browser : that._data.web;
    },

    /**
    * @param {Object} di.locator instance that
    * @access friendly
    */
    _doReverseGeocoding: function(that, lock) {
        that = that || DI.locator;
        var coords = that.getLocation();
        var geocoder = new google.maps.Geocoder();
        lock = lock || false;
        // FIXME: muze se stat, ze google jeste nebude nacteny !
        var latlng = new google.maps.LatLng(coords.lat, coords.lng);
        geocoder.geocode({'latLng': latlng}, function(results, status){
            if ( status == google.maps.GeocoderStatus.OK ) {
                var formatter = new AddressFormatter();
                var formattedAddress = formatter.formatGoogleMapsGeolocatorResults(results);
                if ( formattedAddress ) {
                    that.writeLoc(formattedAddress);
                } // end if
                that.di.spinner.hide();
                var atomizer = new AddressAtomizer(that.di);
                var atomized = atomizer.atomizeGoogleMapsGeolocatorResults(results);
                if ( atomized ) {
                    atomized.lat = coords.lat;
                    atomized.lng = coords.lng;
                    that._send(atomized, null, true, lock);
                } // end if
            } else {
                throw new Error("failed to geocoder.geocode(), status: " + status.toString());
            } // end if
        });
    }, // end method

    writeLoc: function(text) {
        var that = this;
        $('#top-location .top-location-top .actual').text(text);
    }, // end method

    setSaveCallback: function(func) {
        var that = this;
        if ( 'function' == typeof func ) {
            that._saveCallback = func;
        } // end i
    }, // end method

    flash: function() {
        return;
        var that = this;
        var cls = 'flashing';
        var delay = 500;

        $('#top-location .top-location-top .actual').fadeOut().fadeIn();
    }, // end method

    _initAutodetectBtn: function() {
        var that = this;
        $('.autodetect-button').click(function(e){
            e.preventDefault();
            if ( confirm('Autodetect location?') ) {
                that._relocate();
            } // end if
            return false;
        });
    }, // end method

    _relocate: function() {
        var that = this;
        $("#top-location .top-location-top .actual").html('loading...');
        that.reset();
        that.locate(true);
    }, // end func

    lock: function() {
        var that = this;
        this._locked = true;
        var txt = $('#top-location .top-location-top .actual').text();
        $('#top-location .top-location-top .actual').html(that._key + txt);
    }, // end method

    unlock: function() {
        var that = this;
        this._locked = false;
        var txt = $('#top-location .top-location-top .actual').text();
        $('#top-location .top-location-top .actual').text(txt.replace(that._key, ''));
    }, // end method

    isLocked: function() {
        return this._locked;
    }, // end method

}; // end prototype
