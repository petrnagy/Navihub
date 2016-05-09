/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
* @author PN @since 2015-05-01
*/
Browser = {

    /**
    * @static
    * @return Boolean
    */
    isExplorer: function (){
        return ( navigator.userAgent.indexOf('MSIE') > -1 );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isChrome: function (){
        var isChrome = ( navigator.userAgent.indexOf('Chrome') > -1 );
        return ( isChrome && ! Browser.isOpera() );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isSafari: function (){
        var isSafari = ( navigator.userAgent.indexOf("Safari") > -1 );
        return ( isSafari && ! Browser.isChrome() );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isIos: function() {
        if ( navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/iPhone/i) ) {
            if ( ! Browser.isWindowsPhone() ) {
                return true;
            } // end if
        } // end if
        return false;
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isAndroid: function() {
        return ( navigator.userAgent.toLowerCase().indexOf("android") > -1 && ! Browser.isWindowsPhone() );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isWindowsPhone: function() {
        return navigator.userAgent.match(/Windows Phone/i);
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isMobileDevice: function() {
        return ( Browser.isIos() || Browser.isAndroid() || Browser.isWindowsPhone() );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isDesktopDevice: function() {
        return ! Browser.isMobileDevice();
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isFirefox: function (){
        return ( navigator.userAgent.indexOf('Firefox') > -1 );
    }, // end method

    /**
    * @static
    * @return Boolean
    */
    isOpera: function (){
        return ( navigator.userAgent.toLowerCase().indexOf("op") > -1 );
    }, // end func

};
