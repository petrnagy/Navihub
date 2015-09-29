/**
* @author PN @since 2016-09-27
*/
var SearchResult = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResult.prototype = {

    _init: function() {
        var interests = [
            'list-open-in-maps', 'list-plan-a-route', 'list-show-contact', 'list-send-via-email', 'list-get-permalink'
        ];
        var that = this;

        $.each(interests, function(key, interest) {
            $(document).delegate('.' + interest, 'click', function(e) {
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
            var url = that.getDetailUrl(data);

            $.ajax({
                url: url,
                method: 'get',
                cache: true, // <----------- ! ! !
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

    list_get_permalink: function($el) {
      var that = this;
      var data = that.getData($el);
      that.di.spinner.show();
      $.ajax({
          url: '/setpermalink',
          method: 'POST',
          data: { origin: data.origin, id: data.id },
          success: function(data) {
              var url = window.location.origin + '/permalink/' + data.id;
              var txt = '<form class="permalink-form"><textarea onclick="select();">'+url+'</textarea></form><br><a target="_blank" href="'+url+'">Open in new window</a>';
              that.di.messenger.message('Permalink created !', txt);
          }, // end func
          error: function() {
              that.di.messenger.message('Whoops :-(', 'Something went wrong and we could not create the permalink. Please try again later.');
          }, // end func
          complete: function(){
              that.di.spinner.hide();
          }
      }); // end ajax
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

        var url = that.getDetailUrl(data);

        tab.location = url;
        //window.open(url);
    }, // end method

    openSocialShareTab: function(el, tpl) {
        var that = this;
        var $el = $(el).closest('.result-box');
        var data = that.getData($el);
        var url = that.getDetailUrl(data);
        if ( url ) {
            url = tpl.replace('%%URL%%', url);
            window.open(url);
        } else {
            that.di.messenger.message(':-(', 'Sorry, something went wrong during generating the share url address !');
        } // end if
    }, // end method

    getDetailUrl: function(data) {
        return window.location.origin + Detail.prototype.buildDetailUrl(data, this);
    }, // end method

    list_send_via_email: function() {
      var that = this;
      alert("TODO: Napsat metodu, která zpracuje odeslání e-mailu na vloženou adresu");
    }, // end method

    list_share_on_facebook: function(el) {
        this.openSocialShareTab(el, 'https://www.facebook.com/sharer/sharer.php?u=%%URL%%');
    }, // end method

    list_share_on_twitter: function(el) {
        // TODO: Add full status support
        this.openSocialShareTab(el, 'https://twitter.com/home?status=%%URL%%');
    }, // end method

    list_share_on_google_plus: function(el) {
        this.openSocialShareTab(el, 'https://plus.google.com/share?url=%%URL%%');
    }, // end method

    _processDetailError: function(e) {
        // TODO: nejaky normalni handler
        //console.log(e);
        alert(e);
    },

    generateContactPopup: function(data) {
        var that = this;
        var o = '';
        o += '<p class="message-title text-center">' + data.name + '</p>';
        o += '<p class="contact-popup-content">';
        if ( data.detail.phones.length ) {
            o += '<i class="fa fa-phone"></i>' + ' ';
            $.each(data.detail.phones, function(key, val) {
                if (key > 0) o += ', ';
                o += '<a href="tel:'+val+'">' + val + '</a>';
            }); // end foreach
            o += '<br>';
        } else {
            o += '<i class="fa fa-phone"></i>' + ' ' + 'Not found'  + '<br>';
        } // end if

        o += '<i class="fa fa-envelope"></i>' + ' ' + (data.detail.email ? '<a href="mailto:'+data.detail.email+'">' + data.detail.email + '</a>' : 'Not found') + '<br>';

        o += '<i class="fa fa-map-o"></i>' + ' ' + data.address + '<br>';
        o += '<i class="fa fa-map-marker"></i>' + ' ' + data.pretty_loc.lat[0] + '° ' + data.pretty_loc.lat[1] + "' " + data.pretty_loc.lat[2] + '" ' + data.pretty_loc.lat[3] + ', ';
        o += data.pretty_loc.lng[0] + '° ' + data.pretty_loc.lng[1] + "' " + data.pretty_loc.lng[2] + '" ' + data.pretty_loc.lng[3] + '<br>';

        o += '</p>';
        return o;
    }, // end method

}; // end prototype
