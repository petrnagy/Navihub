/**
 * @author PN @since 2014-09-28
 */
var Locator = function(di) {
    this.di = di;
    this._data = {browser: null, web: null};
    this._envelope = {
        lat: null, lng: null, country: null, country_short: null,
        city: null, city2: null, street1: null, street2: null, origin: null
    };
    this._sent = {browser: false, web: false};
    this._interval = null;
    this._saveCallback = null;
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
    _send: function(data, manual) {
        var that = this;
        var cache = that._getFromCache();
        if ( ! cache || cache.lat !== data.lat || cache.lng !== data.lng ) {
            data.set = 1;
            $.ajax({
                url: '/settings/location',
                data: data,
                success: function(){
                    that._saveToCache(data);
                    // load google maps api, do a reverse geocoding and save it as detailed location in local DB
                    var apiUrl = 'https://maps.googleapis.com/maps/api/js?v=3&callback=DI.locator._doReverseGeocoding';
                    var map = new GoogleMap(null, null, null, null, null, apiUrl);
                    var loadedScripts = that.di.turbolinksStorage.get(map.storageKey);
                    loadedScripts = ( null === loadedScripts ? [] : loadedScripts );
                    if ( loadedScripts.indexOf(apiUrl) == -1 ) {
                      that.di.spinner.show();
                      map.loadScripts(null, that.di);
                    } else if ( manual ) {
                      that.di.spinner.show();
                      that._doReverseGeocoding(that);
                    } // end if
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
     * @access friendly
     */
    _doReverseGeocoding: function(that) {
      that = that || DI.locator;
      var coords = that.getLocation();
      var geocoder = new google.maps.Geocoder();
      var latlng = new google.maps.LatLng(coords.lat, coords.lng);
      geocoder.geocode({'latLng': latlng}, function(results, status){
        if ( status == google.maps.GeocoderStatus.OK ) {
          var formatter = new AddressFormatter();
          var formattedAddress = formatter.formatGoogleMapsGeolocatorResults(results);
          if ( formattedAddress ) {
              $('#top-location .top-location-top .actual').text(formattedAddress);
          } // end if
          that.di.spinner.hide();
          var atomizer = new AddressAtomizer(that.di);
          var atomized = atomizer.atomizeGoogleMapsGeolocatorResults(results);
          if ( atomized ) {
            atomized.lat = coords.lat;
            atomized.lng = coords.lng;
            that._send(atomized);
          } // end if
        } else {
          throw new Error("failed to geocoder.geocode(), status: " + status.toString());
        } // end if
      });
    }, // end method
    setSaveCallback: function(func) {
      var that = this;
      if ( 'function' == typeof func ) {
        that._saveCallback = func;
      } // end i
    }, // end method
}; // end prototype
