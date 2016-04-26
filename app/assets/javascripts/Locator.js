/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

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
    this._hooks = [];
    this._weakHooks = [];
    this._interval = null;
    this._saveCallback = null;
    this._didAutomaticReverseGeocoding = false;
    this._initAutodetectBtn();
    this._initLockUnlockBtns();
    this._initLockBtn();
    this._initUnlockBtn();
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
                    that._processHooks();
                    that._processWeakHooks();
                } else if ( ! that._sent.web && that._data.web && ! that._sent.browser ) {
                    that._send(that._data.web, manual, true);
                    that._sent.web = true;
                    that._processWeakHooks();
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
    set: function(location, shallow) {
        var that = this;
        // mask custom location as browser location, thus it will have top priority
        location.origin = 'browser';
        location.lock = 1;
        that._data = {browser: location, web: null};

        if ( shallow ) {
            return;
        } // end if

        if ( that._interval ) {
            clearInterval(that._interval);
        } // end if

        that._interval = null;
        that._send(that._data.browser, true, false, true);
        that._sent = {browser: true, web: true};
        if ( location.formatted ) {
            that.writeLoc(location.formatted);
        } // end if
    }, // end method

    _loadFromBrowser: function() {
        var that = this;
        if (navigator.geolocation) {
            /* be aware: we are not sessing any timeout for this callbacks... */
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
    }, // end method

    _loadFromWeb: function() {
        var that = this;
        $.get("https://ipinfo.navihub.net/", function(response) {
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
                throw new Error("ipinfo response: object expected, got: " + (typeof response) );
            } // end if
        });

    }, // end method

    _send: function(data, manual, write, lock) {
        var that = this;
        var cache = that._getFromCache();
        if ( ! cache || ! that._equals(data, cache) || lock ) {
            lock = ( lock ? true : false );
            data.set = 1;
            data.lock = ( lock ? 1 : 0 );
            $.ajax({
                method: 'POST',
                url: '/settings/location',
                data: data,
                success: function(response) {
                    that._afterSendSuccess(data, manual, write, lock, response);
                } // end func
            });
        } // end if
    }, // end method

    _afterSendSuccess: function(data, manual, write, lock, response) {
        var that = this;

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
        if ( data.origin != 'web' ) {
            if ( ! that.isLocked() ) {
                var apiUrl = that.di.config.googleMapsLibraryUrl;
                var apiCallback = 'DI.locator._doReverseGeocoding';
                that._didAutomaticReverseGeocoding = true;
                that.di.scriptLoader.load(apiUrl, apiCallback);
            } else if ( manual ) {
                that.di.spinner.show();
                that._doReverseGeocoding(that, lock);
                that.flash();
            } // end if // end if
        } // end if

        if ( that._saveCallback ) {
            that._saveCallback();
        } // end if
    }, // end method

    _equals: function(loc1, loc2) {
        var that = this;
        loc1.set = null;
        loc2.set = null;
        loc1.lock = null;
        loc2.lock = null;

        return ( JSON.stringify(loc1) == JSON.stringify(loc2) );
    }, // end method

    _getFromCache: function(deep) {
        if ( deep ) {
            return $.cookie('_navihub_loc_cache');
        } else {
            return ( typeof _navihub_loc_cache == 'object' ? _navihub_loc_cache : null );
        } // end if-else
    }, // end method

    _saveToCache: function(data, deep) {
        if ( deep ) {
            $.cookie('_navihub_loc_cache', data);
        } else {
            _navihub_loc_cache = data;
        } // end if-else
    }, // end method

    _clearCache: function() {
        $.cookie('_navihub_loc_cache', null);
        _navihub_loc_cache = null;
    }, // end method

    setFromCache: function() {
        var that = this;
        var cache = that._getFromCache();
        if ( cache === null ) {
            return false;
        } else {
            that.set(cache, true);
            return true;
        } // end if-else
    }, // end method

    getLocation: function() {
        var that = this;
        var loc = that._data.browser ? that._data.browser : that._data.web;
        if ( loc !== null ) {
            loc.lat = parseFloat(loc.lat);
            loc.lng = parseFloat(loc.lng);
        } // end if
        return loc;
    }, // end method

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
                    //that._data.browser = atomized;
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

    readLoc: function(text) {
        var that = this;
        return $('#top-location .top-location-top .actual').text().replace(that._key, '');
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

    _initLockBtn: function() {
        var that = this;
        $('.loc-lock-button').click(function(e){
            e.preventDefault();
            if ( ! that.isLocked() ) {
                var loc = that.getLocation();
                var loctxt = that.readLoc();
                if ( confirm("Lock current location '" + loctxt + "'?") ) {
                    that.set(loc);
                } // end if
            }  // end if
            return false;
        });
    }, // end method

    _initUnlockBtn: function() {
        var that = this;
        $('.loc-unlock-button').click(function(e){
            e.preventDefault();
            if ( that.isLocked() ) {
                var loc = that.getLocation();
                var loctxt = that.readLoc();
                if ( confirm("Unlock current location '" + loctxt + "'?") ) {
                    that._relocate();
                } // end if
            }  // end if
            return false;
        });
    }, // end method

    _relocate: function() {
        var that = this;
        $("#top-location .top-location-top .actual").html('loading...');
        that.reset();
        that.locate(true);
    }, // end method

    lock: function() {
        var that = this;
        this._locked = true;
        var txt = $('#top-location .top-location-top .actual').text();
        $('#top-location .top-location-top .actual').html(that._key + txt);
        that.hideLockBtn();
        that.showUnlockBtn();
    }, // end method

    unlock: function() {
        var that = this;
        this._locked = false;
        var txt = $('#top-location .top-location-top .actual').text();
        $('#top-location .top-location-top .actual').text(txt.replace(that._key, ''));
        that.showLockBtn();
        that.hideUnlockBtn();
    }, // end method

    _initLockUnlockBtns: function() {
        var that = this;
        if ( that.isLocked() ) {
            that.hideLockBtn();
            that.showUnlockBtn();
        } else {
            that.showLockBtn();
            that.hideUnlockBtn();
        } // end if
    }, // end method

    showLockBtn: function() {
        $('#top-location .top-location-lock').show();
    }, // end method

    hideLockBtn: function() {
        $('#top-location .top-location-lock').hide();
    }, // end method

    showUnlockBtn: function() {
        $('#top-location .top-location-unlock').show();
    }, // end method

    hideUnlockBtn: function() {
        $('#top-location .top-location-unlock').hide();
    }, // end method

    isLocked: function() {
        return this._locked;
    }, // end method

    addHook: function(callback) {
        var that = this;
        if ( that.isLocked() ) {
            callback();
        } else if (that._data.browser) {
            callback();
        } else {
            that._hooks.push(callback);
        } // end if
    }, // end method

    addWeakHook: function(callback) {
        var that = this;
        if ( that.isLocked() ) {
            callback();
        } else if (that.getLocation()) {
            callback();
        } else {
            that._weakHooks.push(callback);
        } // end if
    }, // end method

    _processHooks: function() {
        var hooks = this._hooks;
        this._hooks = [];
        $.each(hooks, function(k, callback) {
            callback();
        }); // end foreach

    }, // end method

    _processWeakHooks: function() {
        var hooks = this._weakHooks;
        this._weakHooks = [];
        $.each(hooks, function(k, callback) {
            callback();
        }); // end foreach

    }, // end method

    doLazyGeocoding: function(addr, $context, callback) {
        var that = this;
        $.ajax({
            url: '/lazy/geocode',
            data: { addr: addr, source: that.di.controller },
            cache: true,
            success: function(data) {
                if ( data && 'ok' == data.status ) {
                    var pretty = '';
                    if (typeof data.html == 'object') {
                        pretty += data.html.lat[0] + '&#176; ';
                        pretty += data.html.lat[1] + "' ";
                        pretty += data.html.lat[2] + '" ';
                        pretty += data.html.lat[3] + '<br>';
                        pretty += data.html.lng[0] + '&#176; ';
                        pretty += data.html.lng[1] + "' ";
                        pretty += data.html.lng[2] + '" ';
                        pretty += data.html.lng[3];
                    } else {
                        pretty += data.html;
                    } // end if-else
                    $context.replaceWith(pretty);

                    if ( typeof callback == 'function' ) {
                        callback(data);
                    } // end if
                } // end if
            }, // end func
        }); // end ajax
    }, // end method

    doLazyReverseGeocoding: function(loc, $context, name, callback) {
        var that = this;
        name = name || null;
        $.ajax({
            url: '/lazy/reversegeocode',
            data: { lat: loc.lat, lng: loc.lng, source: that.di.controller, name: name },
            cache: true,
            success: function(data) {
                if ( data && 'ok' == data.status ) {
                    $context.replaceWith(data.html);
                    if ( typeof callback === 'function' ) {
                        callback(data);
                    } // end if
                } // end if
            }, // end func
        }); // end ajax
    }, // end method

}; // end prototype
