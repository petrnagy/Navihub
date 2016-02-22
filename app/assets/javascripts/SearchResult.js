/**
* @author PN @since 2016-09-27
*/
var SearchResult = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResult.prototype = {

    _init: function() {
        var that = this;
        that._observeInterests();
        that._observeSendViaEmail();
    }, // end method

    _observeInterests: function() {
      var that = this;
      var interests = [
          'list-open-in-maps', 'list-plan-a-route', 'list-send-via-email', 'list-get-permalink',
          'list-fav-switch', 'list-share-on-facebook', 'list-share-on-twitter', 'list-share-on-google-plus',
          'list-visit-website'
      ];

      $.each(interests, function(key, interest) {
          $(document)
          .undelegate('.result-box .' + interest, 'click')
          .delegate('.result-box .' + interest, 'click', function(e) {
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
                method: 'GET',
                cache: true, // <----------- ! ! !
                success: function(data) {
                    callback(data);
                }, // end func
                error: function(data) {
                    throw "Error while loading detail, debug: " + data.toString();
                }, // end func
            }); // end ajax
        } // end if
    }, // end method

    getData: function($el) {
        // TODO: lokalni (globalni) cache
        var that = this;
        var jsonAttr = $el.closest('.result-box').attr('data-result-json');
        var result = null;
        return JSON.parse(jsonAttr);
    }, // end method

    updateData: function($el, data) {
        var that = this;
        var $box = $el.closest('.result-box');
        var jsonAttr = $box.attr('data-result-json');
        result = JSON.parse(jsonAttr);
        combined = $.extend(result, data);
        serialized = JSON.stringify(combined);
        $box.attr('data-result-json', serialized);
        return true;
    }, // end method

    list_open_in_maps: function($el) {
        var that = this;
        that.di.spinner.show();
        // TODO: potrebuje tohle loadDetail?
        var detail = that.loadDetail($el, function(data){
            var url = 'https://www.google.com/maps/embed/v1/place?q=';
            if ( data.geometry.lat !== null && data.geometry.lng !== null ) {
                url += data.geometry.lat.toString() + ',' + data.geometry.lng.toString();
            } else {
                url += data.address;
            } // end if
            url += '&key=' + that.di.config.googleApiPublicKey;
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
            method: 'PUT',
            data: { origin: data.origin, id: data.id },
            success: function(data) {
                var id = 'ta' + uniqueid();
                var url = window.location.origin + '/permalink/' + data.id;
                var txt = '<form class="permalink-form"><textarea id="'+id+'">'+url+'</textarea></form><br><a target="_blank" href="'+url+'">Open in new window</a>';
                that.di.messenger.success('Permalink created !', txt, { onComplete: function(){
                    $('#'+id).focus().select();
                } });
            }, // end func
            error: function() {
                that.di.messenger.message('Whoops :-(', 'Something went wrong and we could not create the permalink. Please try again later.');
            }, // end func
            complete: function(){
                that.di.spinner.hide();
            }
        }); // end ajax
    }, // end method

    list_fav_switch: function($el) {
        var that = this;
        if ( ! $el.hasClass('pending') ) {
            $el.addClass('pending');
            var data = that.getData($el);
            that.di.spinner.show();

            if ( ! $el.hasClass('exists') ) {
                $.ajax({
                    url: '/favorites',
                    data: { origin: data.origin, id: data.id, yield: JSON.stringify(data) },
                    method: 'PUT',
                    success: function(data) {
                        $el.addClass('exists');
                        $el.find('i').removeClass('fa-star-o').addClass('fa-star');
                    }, // end func
                    error: function(data) { that.di.messenger.error('Oh no !', 'There was an error, and we could not add a new favorite item. Please try again later.'); }, // end func
                    complete: function(){
                        that._setCooldown($el);
                        that.di.spinner.hide();
                    }, // end func
                }); // end ajax
            } else {
                var cont = confirm("Remove favorite '"+data.name+"'?");
                if ( true === cont ) {
                    $.ajax({
                        url: '/favorites',
                        data: { origin: data.origin, id: data.id },
                        method: 'DELETE',
                        success: function(data) {
                            $el.removeClass('exists');
                            $el.find('i').removeClass('fa-star').addClass('fa-star-o');
                        }, // end func
                        error: function(data) { that.di.messenger.error('Oh no !', 'There was an error and we could not remove this favorite item. Please try again later.'); }, // end func
                        complete: function(){
                            that._setCooldown($el);
                            that.di.spinner.hide();
                        }, // end func
                    }); // end ajax
                } else {
                    that.di.spinner.hide();
                } // end if-else
            } // end if
        } // end if
    }, // end method

    _setCooldown: function($el) {
        var that = this;
        $el.addClass('pending');
        setTimeout(function(){
            $el.removeClass('pending');
        }, 250);
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
                throw "NULL by that.di.locator.getLocation()";
            } // end if
            url += '&key=' + that.di.config.googleApiPublicKey;
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

    list_visit_website: function(el) {
        var that = this;
        var $el = $(el).closest('.result-box');
        //var tab = window.open('about:blank');
        that.di.spinner.show();
        var detail = that.loadDetail($el, function(data){
            var url = data.detail.website_url;
            if ( ! url ) {
                if ( data.detail.url ) {
                    url = data.detail.url;
                } else {
                    //tab.close();
                    that.di.spinner.hide();
                    that.di.messenger.message(':-(', 'Sorry, could not load the website url address !');
                    return false;
                } // end if
            } // end if
            that.di.spinner.hide();
            //tab.location = url;
            window.location = url;
        });
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

    list_send_via_email: function($el) {
        var that = this;
        var data = that.getData($el);
        var html = '<form class="send-via-email-form" data-id="'+data.id+'" data-origin="'+data.origin+'"><input type="text"><div class="send-via-email-msg"></div><input type="submit" class="btn btn-success pull-right"></form>';
        that.di.messenger.message('Enter your e-mail address', html, {onComplete: function(){
            $('.send-via-email-form > input[type=text]').focus();
        }});
    }, // end method

    _observeSendViaEmail: function() {
        var that = this;
        $(document).delegate('.send-via-email-form', 'submit', function(e){
            e.preventDefault();
            var $form = $(this);
            var $msgwrap = $form.find('.send-via-email-msg');
            var $inputs = $form.find('input');
            var val = $form.find('input[type=text]').val();

            if ( that.di.mixin.validateEmail(val) ) {
                $msgwrap.removeClass('err ok').text('Processing...');
                that.di.spinner.show();
                $.ajax({
                    url: '/sharer/email',
                    method: 'POST',
                    data: { email: val, origin: $form.attr('data-origin').toString(), id: $form.attr('data-id').toString() },
                    success: function(data) {
                        $msgwrap.removeClass('err').addClass('ok').text('Success! You can check filled e-mail address inbox.');
                        $inputs.prop('disabled', true);
                    }, // end func
                    error: function() {
                        $msgwrap.removeClass('ok').addClass('err').text('E-mail processing has failed! Please try again later.');
                    }, // end func
                    complete: function(){
                        that.di.spinner.hide();
                    }, // end func
                }); // end ajax

            } else {
                $form.find('.send-via-email-msg').addClass('err').removeClass('ok').text('This e-mail address does not look good, please fix it.');
            } // end if
            return false;
        });
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
