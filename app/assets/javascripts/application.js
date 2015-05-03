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
//= require turbolinks
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
        controller: controller,
        action: action,
        mixin: Mixin,
        spinner: Spinner,
        browser: Browser,
        turbolinksStorage: new TurbolinksStorage()
    };

    controller = action = null;

    DI.locator = new Locator(DI);

    if ( DI.documentReady ) {
        DI.locator.locate();
    } // end if

    DI.relocate = function(di){
        di.locator.reset();
        di.locator.locate(true);
    }; // end func

    DI.kickstart = 'kickstart_' + DI.controller;
    typeof window[DI.kickstart] === 'function'
            ? window[DI.kickstart](DI)
            : null;

};

$(document).ready(function(){ ready(false); });
$(document).on('page:load', function(){ ready(true); });
