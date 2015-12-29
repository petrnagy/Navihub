var Configurator = {

    configure: function() {

        $.cookie.json = true;

        $.ajaxSetup({
            cache: false,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        });

    }, // end method

    config: {
        googleApiPublicKey: 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI',
        googleMapsLibraryUrl: 'https://maps.googleapis.com/maps/api/js?v=3&libraries=places&callback=',
        mockLocation: { lat: 50.0865876, lng: 14.4159757, origin: 'browser', city: null,
        city2: null, country: null, country_short: null, street1: null, street2: null }
    }

};
