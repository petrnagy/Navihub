var SearchResult = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResult.prototype = {

    _init: function() {
        var interests = ['list-open-in-maps', 'list-plan-a-route',
        'list-show-contact', /*'list-visit-website', 'list-open-detail'*/ 'list-send-via-email',
        'list-share-on-facebook', 'list-share-on-twitter', 'list-share-on-google-plus'];
        var that = this;

        $.each(interests, function(key, interest) {
            $(document).delegate('.' + interest, 'click', function(e){
                e.preventDefault();
                var method = interest.replace(/\-/g, '_');
                that[method]($(this));
                return false;
            });
        }); // end foreach
    }, // end method

    loadDetail: function($el, callback) {
        var that = this;
        var data = that.getData($el);
        if ( data ) {
            var url = '/detail/' + (data.ascii_name ? data.ascii_name.toString() : that.di.mixin.generateRandomHash(5)) + '/' + data.origin.toString() + '?id=' + data.id.toString();

            $.ajax({
                url: url,
                method: 'get',
                cache: true, // ! ! !
                success: function(data) {
                    callback(data);
                }, // end func
                error: function(data) {
                    that._processDetailError(data);
                }, // end func
            }); // end ajax
        } // end if
    }, // end method

    getData: function($el) {
        var that = this;
        var jsonAttr = $el.closest('.result-box').attr('data-result-json');
        var result = null;
        try {
            result = JSON.parse(jsonAttr);
        } catch (e) {
            return that._processDetailError(e);
        } // end try-catch
        return result;
    }, // end method

    list_open_in_maps: function($el) {
        var that = this;
        that.di.spinner.show();
        var detail = that.loadDetail($el, function(data){
            var url = 'https://www.google.com/maps/embed/v1/place?q=';
            if ( data.geometry.lat !== null && data.geometry.lng !== null ) {
                url += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
            } else {
                url += data.address;
            } // end if
            url += '&key=' + that.di.google_api_key_pub;
            $.colorbox({
                html: '<iframe frameborder="0" style="border:0; width: 100%; height: 100%;" src="' + url + '" allowfullscreen></iframe>',
                width: '95%',
                height: '95%',
                //closeButton: false,
                transition: "none",
                fadeOut: 0,
                fixed: true
            });
            that.di.spinner.hide();
        });
    }, // end method

    list_plan_a_route: function($el) {
        var that = this;
        that.di.spinner.show();
        var detail = that.loadDetail($el, function(data){
            var url = 'https://www.google.com/maps/embed/v1/directions?destination=';
            if ( data.geometry.lat !== null && data.geometry.lng !== null ) {
                url += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
            } else {
                url += data.address;
            } // end if
            var coords = that.di.locator.getLocation();
            if ( coords ) {
                url += '&origin=' + coords.lat.toString() + ',' + coords.lng.toString();
            } else {
                return that._processDetailError("NULL by that.di.locator.getLocation()");
            } // end if
            url += '&key=' + that.di.google_api_key_pub;
            $.colorbox({
                html: '<iframe frameborder="0" style="border:0; width: 100%; height: 100%;" src="' + url + '" allowfullscreen></iframe>',
                width: '95%',
                height: '95%',
                //closeButton: false,
                transition: "none",
                fadeOut: 0,
                fixed: true
            });
            that.di.spinner.hide();
        });
    }, // end method

    list_show_contact: function($el) {
        var that = this;
        that.di.spinner.show();
        var detail = that.loadDetail($el, function(data){
            $.colorbox({
                html: that.generateContactPopup(data),
                opacity: 0.5,
                width: '400px',
                height: '200px'
            });
            that.di.spinner.hide();
        });
    }, // end method

    list_visit_website: function(el) {
        var that = this;
        var $el = $(el).closest('.result-box');
        var tab = window.open('about:blank');
        that.di.spinner.show();
        var detail = that.loadDetail($el, function(data){
            var url = data.detail.website_url;
            if ( ! url ) {
                if ( data.detail.url ) {
                    url = data.detail.url;
                } else {
                    tab.close();
                    that.di.messenger.message(':-(', 'Sorry, could not load the website url address !');
                } // end if
            } // end if
            that.di.spinner.hide();
            tab.location = url;
            //window.open(url);
        });
    }, // end method

    list_open_detail: function(el) {
        var that = this;
        var $el = $(el).closest('.result-box');
        var tab = window.open('about:blank');
        var data = that.getData($el);

        if ( ! data ) {
            tab.close();
            that.di.messenger.message(':-(', 'Sorry, something went wrong during generating the detail url address !');
            return;
        } // end if

        var url = '';
        if ( ! that.di.mixin.isAscii(data.id.toString()) ) {
            url = '/detail/' + (data.ascii_name ? data.ascii_name.toString() : that.di.mixin.generateRandomHash(5)) + '/' + data.origin.toString() + '?id=' + data.id.toString();
        } else {
            url = '/detail/' + (data.ascii_name ? data.ascii_name.toString() : that.di.mixin.generateRandomHash(5)) + '/' + data.id.toString() + '/' + data.origin.toString();
        } // end if

        tab.location = url;
        //window.open(url);
    }, // end method

    list_share_on_facebook: function($el) {
        var that = this;
        //https://www.facebook.com/sharer/sharer.php?u=http%3A//www.navihub.net
    }, // end method

    _processDetailError: function(e) {
        // TODO: nejaky normalni handler
        console.log(e);
        alert(e);
    },

    generateContactPopup: function(data) {
        var that = this;
        var o = '';
        o += '<p class="generic-popup-wrapper">';
        o += '<i class="fa fa-phone"></i>' + ' ' + '- - -' + '<br>';
        o += '<i class="fa fa-mobile"></i>' + ' ' + '- - -' + '<br>';
        o += '<i class="fa fa-map-o"></i>' + ' ' + '- - -' + '<br>';
        o += '</p>';
        return o;
    }, // end method

}; // end prototype
