// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require isInViewport.js
//= require turbolinks
//= require colorbox-rails
//= require_tree .

var ready, DI;
ready = function(pageLoad) {

    $.cookie.json = true;

    $.ajaxSetup({
        cache: false,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    });

    DI = {
        pageLoad: pageLoad,
        documentReady: ! pageLoad,
        controller: serverData.controller,
        action: serverData.action,
        mixin: Mixin,
        spinner: Spinner,
        browser: Browser,
        turbolinksStorage: new TurbolinksStorage()
    };

    DI.scriptLoader = new ScriptLoader(DI);
    DI.locator = new Locator(DI);
    DI.messenger = new Messenger(DI);

    if ( serverData.loc.lock ) {
        DI.locator.lock();
    } // end if

    serverData = null;

    if ( DI.documentReady && ! DI.locator.isLocked() ) {
        DI.locator.locate();
    } // end if

    DI.config = {};
    DI.config.googleApiPublicKey = 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI';
    DI.config.googleMapsLibraryUrl = 'https://maps.googleapis.com/maps/api/js?v=3&libraries=places&callback=';
    DI.config.mockLocation = { lat: 50.0865876, lng: 14.4159757, origin: 'browser', city: null,
    city2: null, country: null, country_short: null, street1: null, street2: null };

    // Run the app
    DI.kickstart = 'kickstart_' + DI.controller;
    typeof window[DI.kickstart] === 'function' ? window[DI.kickstart](DI) : null;
};

$(document).ready(function(){ ready(false); });
$(document).on('page:load', function(){ ready(true); });
