/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
 * @author PN @since 2014-09-27
 */
var Input = function(step, di) {
    this.buildUrl = Search.prototype.buildUrl;
    this.di = di;
    this.step = step;
    this.$form = $("#search-input > form");
    this.defaults = {
        sort: 'distance-asc',
        offset: 0,
        radius: 0,
    };
    // order matters !
    this.interests = ['term', 'sort', 'radius', 'offset'];
    if (this.$form.length) {
        this._init();
    } else {
        throw new Error();
    } // end if
}; // end func

Input.prototype = {
    _init: function() {
        var that = this;
        that.di.locator.addWeakHook(function(){
            that.$form.find('button[type="submit"]').prop('disabled', false);
            that._bindSubmit();
        });
        this._initDynamicPlaceholder();
    },
    _bindSubmit: function() {
        var that = this;
        that.$form.submit(function(e) {
            e.preventDefault();
            that.processSubmit();
            return false;
        });
    }, // end method

    processSubmit: function() {
        var that = this;
        var values = that.getValues();
        if (values['term'].length) {
            var url = that.buildUrl(values);
            if (url) {
                that.lock();
                that.pushUrl(url);
                // FIXME: Safari stops css animations when requesting URL (http://stackoverflow.com/questions/25064619/safari-stop-jquery-animation-when-request-link-with-download-header)
                //that.di.spinner.show();
                that.di.loader.show();
            } // end if
        } // end if
    }, // end method

    getValues: function() {
        var that = this;
        return {
            term: that.$form.find("[name='search[term]']").val().trim(),
            radius: that.defaults.radius,
            sort: that.defaults.sort,
            offset: that.defaults.offset,
        };
    }, // end method

    pushUrl: function(url) {
        var that = this;
        window.location.href = url;
    }, // end method

    lock: function() {
        var that = this;
        that.$form.find('input, select, option, button').prop('disabled', true);
    }, // end method

    unlock: function() {
        var that = this;
        that.$form.find('input, select, option, button').prop('disabled', false);
    }, // end method

    _initDynamicPlaceholder: function() {
        var that = this;
        var $input = that.$form.find('input[name="search[term]"]');
        var delay = 100;
        var placeholders = [
            "Pizza", "Water park", "Car rental", "Café", "Chicken wings", "Irish pub",
            "McDonalds", "Hotel", "Post office", "Veterinarian", "Asian fusion restaurant",
            "Sport bar", "ATM", "Bakery", "Beauty salon", "Casino", "Dentist", "Pharmacy",
            "Plumber", "Train station", "Zoo", "Golf", "Beach", "Laser tag", "Music school",
            "Hot dogs", "KFC", "Dunkin' Donuts", "Wendy's", "Burger King", "Internet cafe",
            "Shoe repair", "Petrol station", "Gas station", "Grocery", "Pretzels", "Ice cream"
        ];
        shuffle(placeholders);
        placeholders = ["What are you looking for…?"].concat(placeholders);
        var i = 0, j = 0;
        var text = '';
        var skip = 10;
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
            if ( text.length && $input.attr('placeholder') !== text ) {
                $input.attr('placeholder', text);
            } // end if
        }, delay);
    }, // end method

}; // end prototype
