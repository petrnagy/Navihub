/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
 * @author PN @since 2017-03-03
 */
var HomepageDynamicHeading = function(di) {
    this.di = di;
    this.$box = $('#hp-heading > .colored');
    if (this.$box.length) {
        this._init();
    } else {
        throw new Error();
    } // end if
}; // end func

HomepageDynamicHeading.prototype = {
    _init: function() {
        this._initDynamicHeading();
    },

    _initDynamicHeading: function() {
        var that = this;
        var delay = 75;
        var placeholders = [
            "Pizza", "Water park", "Car rental", "Café", "Chicken wings", "Irish pub",
            "McDonalds", "Hotel", "Post office", "Cinema", "Winery",
            "Sport bar", "ATM", "Bakery", "Beauty salon", "Casino", "Minigolf", "Yoga class",
            "Pizza hut", "Blackjack", "Zoo", "Golf", "Beach", "Laser tag", "Music school",
            "Hot dogs", "KFC", "Donuts", "Wendy's", "Burger King", "Burgers",
            "Bowling", "Disco", "Beer bar", "Grocery", "Pretzels", "Ice cream",
            "News stand"
        ];
        shuffle(placeholders);
        //placeholders = ["Anything"].concat(placeholders);
        var i = 0, j = 0;
        var text = '';
        var skip = 20;
        var interval = setInterval(function(){
            if ( skip > 0 ) {
                --skip;
            } else {
                if ( i < placeholders.length ) {
                    if ( j < placeholders[i].length ) {
                        text += placeholders[i][j];
                        ++j;
                    } else {
                        ++i; j = 0;
                        text = '';
                        skip = 30;
                    } // end if
                } else {
                    i = 0; j = 0;
                    skip = 30;
                } // end if
            } // end if
            if ( text.length && that.$box.text() !== text ) {
                that.$box.text(text);
            } // end if
        }, delay);
    }, // end method

}; // end prototype
