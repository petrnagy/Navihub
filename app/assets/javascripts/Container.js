var Container = {

    build: function(pageLoad, serverData, configurator) {

        var DI = {
            pageLoad: pageLoad,
            documentReady: ! pageLoad,
            controller: serverData.controller,
            action: serverData.action,
            mixin: Mixin,
            spinner: Spinner,
            browser: Browser,
            turbolinksStorage: new TurbolinksStorage()
        };

        DI.burger = new BurgerMenu(DI);
        DI.marker = new MarkerMenu(DI);
        DI.scriptLoader = new ScriptLoader(DI);
        DI.locator = new Locator(DI);
        DI.messenger = new Messenger(DI);

        DI.config = $.extend(configurator.config, {
            // foo: 'bar',
        });
        // DI.config.googleApiPublicKey = 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI';
        // DI.config.googleMapsLibraryUrl = 'https://maps.googleapis.com/maps/api/js?v=3&libraries=places&callback=';
        // DI.config.mockLocation = { lat: 50.0865876, lng: 14.4159757, origin: 'browser', city: null,
        // city2: null, country: null, country_short: null, street1: null, street2: null };

        if ( serverData.loc.lat !== null && serverData.loc.lng !== null ) {
            var mock = DI.config.mockLocation;
            if ( serverData.loc.lock ) {
                DI.locator.lock();
            } // end if
            mock.lat = serverData.loc.lat;
            mock.lng = serverData.loc.lng;
            DI.locator.set(mock, true);
            mock = null;
        } // end if

        /* @see: pageLoad is not real page load ! */
        if ( ! DI.pageLoad ) {
            if ( ! DI.locator.isLocked() ) {
                DI.locator.reset();
                DI.locator.locate();
            } // end if
        } else {
            DI.locator.setFromCache();
        } // end if

        //if ( ! DI.pageLoad && null === DI.locator.getLocation() ) {

        //} // end if

        // Run the app
        DI.kickstart = 'kickstart_' + DI.controller;

        return DI;

    }, // end method

};
