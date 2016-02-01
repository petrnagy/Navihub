/**
 * @author PN @since 2014-09-28
 */
var VenueDetail = function(di) {
    this.di = di;
    this._data = null;
    this._init();
}; // end func

VenueDetail.prototype = {
    _init: function() {
        var that = this;
        that._data = that._loadDetailData();
        that._initDetailMap();
        this._initEmailSharing();
        this._initFavoriteBtn();
    },
    getData: function() {
      return this._data;
    }, // end method
    _initDetailMap: function() {
        var that = this;
        var interval = setInterval(function() {
            var location = that.di.locator.getLocation();
            if (location && typeof location.lat !== 'undefined' && typeof location.lng !== 'undefined') {
                clearInterval(interval);
                new VenueDetailGoogleMap(that.di, {latitude: location.lat, longitude: location.lng}, 'map_canvas', 14, function() {
                    if (that.di.detailGoogleMap && that._data) {
                        that.di.detailGoogleMap.addRoute(
                                {latitude: location.lat, longitude: location.lng},
                        {latitude: that._data.geometry.lat, longitude: that._data.geometry.lng},
                        'WALKING');
                    } // end if
                });
            } // end if
        }, 100);
    },
    _loadDetailData: function() {
        return JSON.parse($("#detail-results").attr('data-detail-json'));
    },
    _initEmailSharing: function() {
      var that = this;
      var $form = $('form#detail-share-via-email');
      var $input = $('input[name="detailshare-email"]');

      $form.submit(function(e){
          e.preventDefault();
          var data = { id: null, origin: null, email: null };
          data.id = that._data.id;
          data.origin = that._data.origin;
          data.email = $input.val();

          if ( ! that.di.mixin.validateEmail(data.email) ) {
              that.di.messenger.error(':-(', 'Please correct your email address before continuing.<br> "' + data.email.toString() + '" is not a valid email address.');
              return;
          } // end if

          that.di.spinner.show();
          $.ajax({
              url: '/sharer/email',
              method: 'post',
              data: data,
              success: function(result) {
                  if ( result.status == 'ok' ) {
                      $input.select();
                      that.di.messenger.success('Success !', 'Good! Your message to "' + data.email + '" is on the way.');
                  } else {
                      that.di.messenger.error(':-(', 'Oh no! There has been an error! Please try again later.');
                  } // end if
              }, // end func
              error: function() {
                  $(this).submit();
              }, // end func
              complete: function(){
                  that.di.spinner.hide();
              } // end func
          }); // end ajax
          return false;
      });
    }, // end method
    _initFavoriteBtn: function() {
      var that = this;
      var $btn = $('a.detail-fav-switch');
      $btn.click(function(e){
          e.preventDefault();
          if ( ! $btn.hasClass('pending') ) {
              that.di.spinner.show();
              $btn.addClass('pending');
              var data = { origin: that._data.origin, id: that._data.id };

              if ( ! $btn.hasClass('exists') ) {
                  $.ajax({
                      url: '/favorites',
                      data: { origin: data.origin, id: data.id, yield: null },
                      method: 'PUT',
                      success: function(response) {
                          $btn.addClass('exists');
                          $btn.find('i').removeClass('fa-star-o').addClass('fa-star');
                      }, // end func
                      error: function(response) { that.di.messenger.error('Oh no !', 'There was an error, and we could not add a new favorite item. Please try again later.'); }, // end func
                      complete: function(){
                          that._setCooldown($btn);
                          that.di.spinner.hide();
                      }, // end func
                  }); // end ajax
              } else {
                  var cont = confirm("Remove favorite '"+that._data.name+"'?");
                  if ( true === cont ) {
                      $.ajax({
                          url: '/favorites',
                          data: { origin: data.origin, id: data.id },
                          method: 'DELETE',
                          success: function(response) {
                              $btn.removeClass('exists');
                              $btn.find('i').removeClass('fa-star').addClass('fa-star-o');
                          }, // end func
                          error: function(response) { that.di.messenger.error('Oh no !', 'There was an error and we could not remove this favorite item. Please try again later.'); }, // end func
                          complete: function(){
                              that._setCooldown($btn);
                              that.di.spinner.hide();
                          }, // end func
                      }); // end ajax
                  } else {
                      that.di.spinner.hide();
                  } // end if-else
              } // end if-else
          } // end if
          return false;
      });
    }, // end method
    _setCooldown: function($el) {
        var that = this;
        setTimeout(function(){
            $el.removeClass('pending');
        }, 250);
    }, // end method
}; // end prototype
