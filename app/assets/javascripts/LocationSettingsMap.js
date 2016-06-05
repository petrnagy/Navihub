/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
* @author PN @since 2015-01-30
*/
var LocationSettingsMap = function(di, location) {
    this.di = di;
    this.initialZoom = 5;
    var currentLocation = this.di.locator.getLocation();
    if (currentLocation) {
        location = currentLocation;
        this.initialZoom = 12;
    } // end if
    this.location = location;
    this.location.latitude = this.location.lat;
    this.location.longitude = this.location.lng;
    this.googleMap = null;
}; // end func

LocationSettingsMap.prototype = {
    init: function() {
        var that = this;
        that._initMap();
        that._initForm();
        // HACK: for focusing the map input
        var selector = '#settings-location-autocomplete', interval = setInterval(function(){
            $(selector).focus();
            if ( $(selector).is(':focus') ) {
                clearInterval(interval);
            } // end if
        }, 1000);
    }, // end method

    _initMap: function() {
        var that = this;

        that.googleMap = new LocationSettingsGoogleMap(that.di, that.location, 'settings-location-canvas', that.initialZoom, function() {
            var input = document.getElementById('settings-location-autocomplete');

            //var types = document.getElementById('type-selector');
            that.googleMap.map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
            //that.googleMap.map.controls[google.maps.ControlPosition.TOP_LEFT].push(types);

            var autocomplete = new google.maps.places.Autocomplete(input);
            autocomplete.bindTo('bounds', that.googleMap.map);
            autocomplete.setTypes([]); // all

            var infoWindow = new google.maps.InfoWindow();
            var marker = new google.maps.Marker({
                map: that.googleMap.map,
                anchorPoint: new google.maps.Point(0, -29)
            });
            that._initAutocomplete(autocomplete, infoWindow, marker);
        });
    }, // end method

    _initForm: function() {
        var that = this;

        // disable enter key for autocomplete (wants to submit form, but we dont)
        $('#settings-location-autocomplete').keypress(function(e){
            if(e.which == 13) { // 13 = enter
                e.preventDefault();
                return false;
            } // end if
        });

        var $form = $('form#settings-location');
        $form.submit(function(e){
            e.preventDefault();
            that.di.locator.set(that.location);
            var flashmsg = '<div class="alert alert-dismissible alert-success"><button type="button" class="close" data-dismiss="alert">&times;</button>%%flashmsg%%</div>';
            flashmsg = flashmsg.replace('%%flashmsg%%', 'Location has been successfully changed. <a href="/">Continue?</a>');
            $('#yield').prepend(flashmsg);
            return false;
        });
    }, // end method

    _initAutocomplete: function(autocomplete, infoWindow, marker) {
        var that = this;
        google.maps.event.addListener(autocomplete, 'place_changed', function() {
            infoWindow.close();
            marker.setVisible(false);
            var place = autocomplete.getPlace();

            if (!place || !place.geometry) {
                return;
            } // end if

            if (place.geometry.viewport) {
                that.googleMap.map.fitBounds(place.geometry.viewport);
            } else {
                that.googleMap.map.setCenter(place.geometry.location);
                that.googleMap.map.setZoom(17);
            }
            marker.setIcon(({
                url: place.icon,
                size: new google.maps.Size(71, 71),
                origin: new google.maps.Point(0, 0),
                anchor: new google.maps.Point(17, 34),
                scaledSize: new google.maps.Size(35, 35)
            }));
            marker.setPosition(place.geometry.location);
            marker.setVisible(true);

            var address = '';
            if (place.address_components) {
                address = arrayUnique([
                    (place.address_components[0] && place.address_components[0].short_name || ''),
                    (place.address_components[1] && place.address_components[1].short_name || ''),
                    (place.address_components[2] && place.address_components[2].short_name || ''),
                    (place.address_components[3] && place.address_components[3].short_name || '')
                ]).join(', ');
            }

            infoWindow.setContent('<div><strong>' + place.name + '</strong><br>' + address);
            infoWindow.open(that.googleMap.map, marker);

            var currentLoc = that.di.config.mockLocation;
            currentLoc.lat = place.geometry.location.lat();
            currentLoc.lng = place.geometry.location.lng();
            currentLoc.formatted = address;

            that.location = currentLoc;
        });
    } // end method

};
