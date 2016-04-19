/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

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
        that._initEmailSharing();
        that._initFavoriteBtn();
        that._initPermalinkBtn();
    },

    getData: function() {
      return this._data;
    }, // end method

    setVenueLocation: function(loc) {
      var that = this;
      that._data.geometry = loc;
    }, // end method

    _initDetailMap: function() {
        var that = this;
        var interval = setInterval(function() {
            var location = that.di.locator.getLocation();
            if ( location && that._data.geometry ) {
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
    }, // end method

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
              method: 'POST',
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

    _initPermalinkBtn: function() {
      var that = this;
      var $btn = $('.col-permalink .btn-permalink');

      $btn.click(function(e){
          e.preventDefault();
          if ( $btn.prop('disabled') !== true ) {
              that.di.spinner.show();
              $btn.prop('disabled', true);
              $.ajax({
                  url: '/setpermalink',
                  data: { id: that._data.id, origin: that._data.origin },
                  method: 'PUT',
                  success: function(data) {
                      var id = 'ta' + uniqueid();
                      var url = window.location.origin + '/permalink/' + data.id;
                      var txt = '<form class="permalink-form"><textarea id="'+id+'">'+url+'</textarea></form><br><a target="_blank" href="'+url+'">Open in new window</a>';
                      that.di.messenger.success('Permalink created', txt, { onComplete: function(){
                          $('#'+id).focus().select();
                      } });
                      $btn.prop('disabled', false);
                      that.di.spinner.hide();
                  }, // end func
                  error: function() {
                      that.di.messenger.error('Whoops :-(', 'Something went wrong while creating the permalink. Please try again later.');
                      $btn.prop('disabled', false);
                      that.di.spinner.hide();
                  }, // end func
              }); // end ajax
          } // end if
          return false;
      });
    }, // end method

}; // end prototype
