/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
* @author PN @since 2014-08-30
*/
var Search = function(step, di) {
    this.di = di;
    this.step = step;
    this.$form = $("#search-form > form");
    this.defaults = {
        sort: 'distance-asc',
        offset: 0,
        radius: 0,
    };
    // order matters !
    this.interests = ['term', 'sort', 'radius', 'offset'];
    if (this.$form.length) {
        this._init();
    } // end if
}; // end func

Search.prototype = {
    _init: function() {
        var that = this;
        that.di.locator.addWeakHook(function(){
            that._bindSubmit();
        });
        that._bindChange();
        that._bindFocus();
    },
    _bindSubmit: function() {
        var that = this;
        that.$form.find('button[type="submit"]').prop('disabled', false);
        that.$form.submit(function(e) {
            e.preventDefault();
            that.ajaxSubmit();
            return false;
        });
    }, // end method

    _bindChange: function() {
        var that = this;
        that.$form.find("input[type='text'], select").change(function() {
            that.$form.find("[name='search[offset]']").val(0);
        });
    }, // end method

    ajaxSubmit: function(append, values) {
        var that = this;
        values = ('object' == typeof values ? values : that.getValues());
        if (values.term.length) {
            var url = that.buildUrl(values);
            if (url) {
                that.pushUrl(url);
                that.lock();
                that.di.loader.show();
                $.ajax({
                    url: url,
                    data: {append: Number(typeof append != 'undefined' && append), ui: Number($('#search-form').length > 0)},
                    success: function(data) {
                        if (append) {
                            $("#search-results").append(data);
                        } else {
                            $("#search-results").html(data).removeClass('search-start');
                            that.updateTitle();
                        } // end if
                        that.di.loader.hide();
                        that.unlock();
                        that.di.lazyLoader.lazyLoad();
                    }, // end func
                    error: function() {
                        that.di.loader.hide();
                        that.unlock();
                        that.di.messenger.error('Whoops !', 'We are sorry, the server has encountered an unexpected error and could not complete your request. Please try again later.');
                    } // end func
                });
            } // end if
        } // end if
    }, // end method

    updateUrl: function() {
        var that = this;
        that.pushUrl(that.buildUrl(that.getValues()));
    }, // end method

    getValues: function() {
        var that = this;
        return {
            term: that.$form.find("[name='search[term]']").val().trim(),
            sort: that.$form.find("[name='search[sort]'] option:selected").val(),
            radius: parseInt(that.$form.find("[name='search[radius]'] option:selected").val(), 10),
            offset: parseInt(that.$form.find("[name='search[offset]']").val(), 10),
        };
    }, // end method

    buildUrl: function(values) {
        var that = this;
        var url = '';
        if (window.location.origin) {
            url += window.location.origin;
        } else {
            url += 'http://' + window.location.host;
        } // end if
        var baseUrl = url;
        var ascii = true;
        url += '/search';
        $.each(that.interests, function(k, v) {
            var val = (typeof values[v] !== 'undefined' && values[v] ? values[v] : that.defaults[v]);
            if ( 'term' === v ) {
                url += '/%%term%%';
            } else {
                url += '/' + encodeURIComponent(val);
            } // end if-else
            if (!that.di.mixin.isAscii(val)) {
                ascii = false;
            } // end if
        });
        var loc = null;
        if ( values.loc ) {
            loc = values.loc;
        } else {
            loc = that.di.locator.getLocation();
        }
        var ll = loc.lat. toFixed(7).toString() + ',' + loc.lng. toFixed(7).toString();
        url += '/@/' + ll;
        values.term = values.term.replace('/', ',');
        if ( ascii ) {
            url = url.replace('/%%term%%', '/' + values.term);
        } else {
            url = url.replace('/%%term%%', '');
            url += '?term=' + values.term;
        } // end if-else
        return url;
    }, // end method

    pushUrl: function(url) {
        var that = this;
        try {
            if (url != window.location.href) {
                window.history.pushState(null, null, url);
            } // end if
            return true;
        } catch (e) { // IE9 and lower
            window.location = url;
            return false;
        } // end try-catch
    }, // end method

    lock: function() {
        var that = this;
        that.$form.find('input, select, option, button').prop('disabled', true);
    }, // end method

    unlock: function() {
        var that = this;
        that.$form.find('input, select, option, button').prop('disabled', false);
    }, // end method

    updateTitle: function() {
        var that = this;
        var title = $("#search-results").find('h1').first().text();
        if ( title && title.length > 3 ) { // Length 3 is for smile. We do not want smile in the <title>.
            $('title').text(title);
        } // end if
    }, // end method

    _bindFocus: function() {
        var that = this;
        if ( that.di.browser.isMobileDevice() ) {
            that.$form.find('input[type="text"]').focus(function(){
                var elem = this;
                setTimeout(function(){ elem.selectionStart = elem.selectionEnd = 10000; }, 0);
            });
        } // end if
    }, // end method

}; // end prototype
