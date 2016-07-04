/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var Configurator = {

    configure: function() {

        $.cookie.json = true;

        $.ajaxSetup({
            cache: false,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            accepts: 'application/json',
        });

        $('a[href^="#"]').smoothScroll();
        //$('link.main-stylesheet').attr('media', 'all');

    }, // end method

    config: {
        /* BEWARE! The key is included two times ! */
        googleApiPublicKey: 'AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI',
        googleMapsLibraryUrl: 'https://maps.googleapis.com/maps/api/js?key=AIzaSyA5cs8HLvnlV99e9t_Q_2HWL8xmWF6quaI&language=en&v=3&libraries=places&callback=',
        mockLocation: { lat: 50.0865876, lng: 14.4159757, origin: 'browser', city: null,
        city2: null, country: null, country_short: null, street1: null, street2: null }
    },

    errorHandler: function(msg, url, line, col, error) {
        var extra = !col ? '' : '\ncolumn: ' + col.toString();
        extra += !error ? '' : '\nerror: ' + error.toString();
        var summary = "Error: " + msg + "\nurl: " + url + "\nline: " + line + extra;

        var data = {
            summary:    summary,
            msg:        msg,
            url:        url,
            line:       line,
            extra:      extra,
            details:    {}
        };

        if ( typeof Browser === 'object' ) {
            $.each(['isExplorer', 'isChrome', 'isSafari', 'isFirefox', 'isOpera'], function(key, method) {
                data.details[method] = Browser[method]();
            }); // end foreach
        } // end if
        if ( typeof navigator.appVersion === 'string' ) {
            data.details.browserVersion = navigator.appVersion;
        } // end if

        $.ajax({
            url: '/logger/js',
            cache: false,
            method: 'POST',
            data: data
        }); // end ajax

        // return true => error will not be shown in browser (mostly IE)
        return true;
    } // end method

};
