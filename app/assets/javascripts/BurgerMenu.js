/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var BurgerMenu = function(di) {
    this.di = di;
    this.burger = '#burger-menu';
    this.menus = '#menu-top, #menu-alt';
    this._init();
}; // end func

BurgerMenu.prototype = {

    _init: function() {
        this._initBurger();
    }, // end method

    _initBurger: function() {
        var that = this;
        var $burger = $(that.burger);
        var $menus = $(that.menus);

        $burger.find('a').click(function(e) {
            e.preventDefault();
            if ($menus.is(':visible')) {
                that.close();
            } else {
                that.di.marker.close();
                that.open();
            } // end if-else
            return false;
        });
    }, // end method

    active: function() {
        var that = this;
        var $burger = $(that.burger);
        return $burger.is(':visible');
    }, // end method

    open: function() {
        var that = this;
        if ( that.active() ) {
            var $menus = $(that.menus);
            $menus.slideDown();
        } // end if
    }, // end method

    close: function() {
        var that = this;
        if ( that.active() ) {
            var $menus = $(that.menus);
            $menus.slideUp();
        } // end if
    }, // end method

}; // end prototype
