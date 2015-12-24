/**
 * @author PN @since 2014-08-30
 */
var Search = function(step, di) {
    this.di = di;
    this.step = step;
    this.$form = $("#search-form");
    this.defaults = {
        sort: 'distance-asc',
        offset: 0,
        radius: 0,
    };
    // order matters !
    this.interests = ['term', 'radius', 'sort', 'offset'];
    if (this.$form.length) {
        this._init();
    } else {
        throw new Error();
    } // end if
}; // end func

Search.prototype = {
    _init: function() {
        this._bindSubmit();
        this._bindChange();
    },
    _bindSubmit: function() {
        var that = this;
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

    ajaxSubmit: function(append) {
        var that = this;
        var values = that.getValues();
        if (values['term'].length) {
            var url = that.buildUrl(values);
            if (url) {
                that.pushUrl(url);
                that.lock();
                that.di.spinner.show();
                $.ajax({
                    url: url,
                    data: {append: Number(typeof append != 'undefined' && append)},
                    success: function(data) {
                        if (append) {
                            $("#search-results").append(data);
                        } else {
                            $("#search-results").html(data).removeClass('search-start');
                        } // end if
                        that.di.spinner.hide();
                        that.unlock();
                        that.di.lazyLoader.lazyLoadSearchResultsImages();
                    }, // end func
                    error: function() {
                        that.di.spinner.hide();
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
            radius: parseInt(that.$form.find("[name='search[radius]'] option:selected").val(), 10),
            sort: that.$form.find("[name='search[sort]'] option:selected").val(),
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
            var val = (typeof values[v] != 'undefined' && values[v] ? values[v] : that.defaults[v]);
            url += '/' + encodeURIComponent(val);
            if (!that.di.mixin.isAscii(val)) {
                ascii = false;
            }
        });
        var loc = that.di.locator.getLocation();
        var ll = 'll=' + loc.lat.toString() + ',' + loc.lng.toString();
        if (ascii) {
            return url + '?' + ll;
        } else {
            url = baseUrl;
            url += '/find';
            var char = '?';
            $.each(that.interests, function(k, v) {
                if (typeof values[v] != 'undefined' && values[v] && values[v] != that.defaults[v]) {
                    url += char + v + '=' + encodeURIComponent(values[v]);
                    char = '&';
                } // end if
            });
            return url + '&' + ll;
        } // end if
    }, // end method

    pushUrl: function(url) {
        var that = this;
        try {
            if (url != window.location.href) {
                window.history.pushState(null, null, url);
            } // end if
            return true;
        } catch (e) { // IE9 and lower
            // FIXME: Jak false? co s tim dal???
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

}; // end prototype
