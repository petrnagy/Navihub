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
    this._requestLocation = null;
    this._key = '<i class="fa fa-key" title="Address is locked. Click \'autodetect\' to unlock it."></i>&nbsp;';
    this._data = {browser: null, web: null};
    this._envelope = {
        lat: null, lng: null, country: null, country_short: null,
        city: null, city2: null, street1: null, street2: null, origin: null
    };
    this._strongHookTimeout = 10000;
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
    this._initRequestLocation();
}; // end func

Locator.prototype = {

    locate: function(manual, write) {
        var that = this;
        that._loadFromBrowser();
        that._loadFromWeb();
        that._interval = setInterval(function() {
            if (that._sent.browser) {
                clearInterval(that._interval);
            } else {
                if ( ! that._sent.browser && that._data.browser ) {
                    that._send(that._data.browser, manual, write);
                    that._sent.browser = true;
                    that._processHooks();
                    that._processWeakHooks();
                } else if ( ! that._sent.web && that._data.web && ! that._sent.browser ) {
                    that._send(that._data.web, manual, true);
                    that._sent.web = true;
                    that._processWeakHooks();
                    setTimeout(function(){
                        if ( that._sent.browser !== true ) {
                            that._processHooks();
                        } // end if
                    }, that._strongHookTimeout);
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
        var cached = that._getFromCache(true);
        if ( cached !== null ) {
            that._data.browser = cached;
        } else {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(response) {
                    try {
                        var data = that.di.mixin.clone(that._envelope);
                        data.lat = response.coords.latitude;
                        data.lng = response.coords.longitude;
                        data.origin = 'browser';
                        that._data.browser = data;
                        that._saveToCache(data, true);
                    } catch (e) {
                        that._data.browser = false;
                    } // end try-catch
                }, function(response) {
                    var msg = '';
                    if ( typeof response == 'object' && response.code == 1 ) {
                        msg = 'Please allow our site to access your <b>geolocation</b> for the best possible user experience. <a href="https://www.google.cz/#q=how+to+enable+browser+geolocation">How?</a>';
                    } else {
                        // do not bother user with this, most of them are from big cities anyway...
                        //msg = 'We could not guess your location and therefore the site functionality may be limited. (<a href="/" onclick="window.location.reload(); return false;">reload</a>)';
                    } // end if
                    if ( msg.length ) {
                        var flashmsg = '<div class="alert alert-dismissible alert-info"><button type="button" class="close" data-dismiss="alert">&times;</button>%%flashmsg%%</div>';
                        flashmsg = flashmsg.replace('%%flashmsg%%', msg);
                        $('#yield').prepend(flashmsg);
                    } // end if
                    that._data.browser = false;
                }, { enableHighAccuracy: true, timeout: 300000, maximumAge: 60000 });
            } else {
                that._data.browser = false;
            } // end if
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
                    that.di.spinner.hide();
                } // end func
            });
        } else if ( manual ) {
            that.di.spinner.hide();
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
                // FIXME: Pri autodetekci se _doReverseGeocoding nezavola podruhe...
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
            var timeout = 60; // 60s
            var cached = $.cookie('_navihub_loc_cache');
            if ( cached !== undefined ) {
                if ( cached._ts !== undefined ) {
                    if ( ( (new Date().getTime() / 1000) - cached._ts) < timeout )  {
                        return cached;
                    } // end if
                } // end if
            } // end if
            return null;
        } else {
            return ( typeof _navihub_loc_cache == 'object' ? _navihub_loc_cache : null );
        } // end if-else
    }, // end method

    _saveToCache: function(data, deep) {
        if ( deep ) {
            data._ts = new Date().getTime() / 1000;
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

    getRequestLocation: function() {
        var that = this;
        return that._requestLocation;
    }, // end method

    getRequestLocationTxt: function() {
        var that = this;
        if ( that._requestLocation !== null ) {
            return that._requestLocation.lat.toString() + ',' + that._requestLocation.lng.toString();
        } else {
            return null;
        } // end if
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
        //$("#top-location .top-location-top .actual").html('loading...');
        that.di.spinner.show();
        that.reset();
        that.locate(true, true);
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
                    if (typeof data.html == 'object') { // search / favorites
                        pretty += data.html.lat[0] + '&#176; ';
                        pretty += data.html.lat[1] + "' ";
                        pretty += data.html.lat[2] + '" ';
                        pretty += data.html.lat[3] + ', ';
                        pretty += data.html.lng[0] + '&#176; ';
                        pretty += data.html.lng[1] + "' ";
                        pretty += data.html.lng[2] + '" ';
                        pretty += data.html.lng[3];
                    } else { // detail / permalink
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

    _initRequestLocation: function() {
        var that = this;
        var locString = $('body').attr('data-request-ll');
        if ( locString.length ) {
            var loc = locString.split(',');
            that._requestLocation = { lat: parseFloat(loc[0]), lng: parseFloat(loc[1]) };
        } // end if
    }, // end method

}; // end prototype
