/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var Container = {

    build: function(pageLoad, serverData, configurator) {

        var DI = {
            pageLoad: pageLoad,
            documentReady: ! pageLoad,
            controller: serverData.controller,
            action: serverData.action,
            env: serverData.env,
            mixin: Mixin,
            spinner: Spinner,
            loader: Loader,
            browser: Browser,
            turbolinksStorage: new TurbolinksStorage(),
            ellipsis: new Ellipsis(),
            ENVIRONMENT: { DEV: 'development', PROD: 'production', TEST: 'testing' }
        };

        if ( DI.env == DI.ENVIRONMENT.PROD ) {
            window.onerror = configurator.errorHandler;
        } // end if

        DI.burger = new BurgerMenu(DI);
        DI.marker = new MarkerMenu(DI);
        DI.scriptLoader = new ScriptLoader(DI);
        DI.locator = new Locator(DI);
        DI.messenger = new Messenger(DI);

        DI.config = $.extend(configurator.config, {
            // foo: 'bar',
        });

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
        if ( ! DI.pageLoad || ! DI.locator.setFromCache() ) {
            if ( ! DI.locator.isLocked() ) {
                DI.locator.reset();
                DI.locator.locate();
            } // end if
        }  // end if

        DI.browser.detect();

        // Run the app
        DI.kickstart = 'kickstart_' + DI.controller;

        return DI;

    }, // end method



};
