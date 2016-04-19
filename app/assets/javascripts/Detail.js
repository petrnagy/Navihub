/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
* @author PN @since 2014-09-28
*/
var Detail = function($cube, di) {
    if ($cube.length) {
        this.di = di;
        this.id = $cube.attr('id');
        this._$cube = $cube;
        this._$detail = null;
        this._columns = 3;
        this._init();
    } // end if
}; // end func

Detail.prototype = {
    _init: function() {
        var that = this;
    },
    switch : function() {
        var that = this;

        if (that.isOpen()) {
            that._close();
            that._setCloseState();
        } else {
            that._closeOthers();
            that._open();
            var pos = ($('.detail-wrapper').offset().top - 135);
            $("html").animate({scrollTop: pos}, 500, 'swing', function() {
                that._loadDetail();
            });

        } // end if
    },
    _open: function() {
        var that = this;
        var hash = that.di.mixin.generateRandomHash(20);
        that._$detail = that._buildDetailRow();
        that._$detail.attr('data-cube-rel', hash);
        that._$cube.attr('data-cube-rel', hash);
        var prevCount = that._$cube.prevAll().length;
        var offset = that._columns - (prevCount % that._columns);
        var $nextAll = that._$cube.nextAll();
        var index = null;
        var $next = null;
        if ($nextAll.length === 0) {
            that._$cube.after(that._$detail);
        } else {
            if ($nextAll.length < offset) { // last row
                index = $nextAll.length - 1;
            } else if ($nextAll.length >= offset) { // somewhere middle
                index = offset - 2;
            } else { // first row
                index = $nextAll.length - 2;
            } // end if
            $next = $nextAll.eq(index < 0 ? 0 : index);
            if (index >= 0) {
                $next.after(that._$detail);
            } else {
                $next.before(that._$detail);
            } // end if
        } // end if

        that._$detail.addClass('active');
        that._$cube.addClass('active');
        that.setOpenState();
    },
    _loadDetail: function() {
        var that = this;
        var jsonAttr = that._$cube.attr('data-result-json');
        var result = JSON.parse(jsonAttr);

        if (result.geometry.lat === null || result.geometry.lng === null) {
            if (result.address) {
                var geocode = new GoogleGeocode(result.address);
                geocode.load(function(coords) {
                    if (coords !== null) {
                        result.geometry = coords;
                        that._loadDetailDeferred(result);
                    } else {
                        throw new Error('Could not load detail map, geocode failed');
                    } // end if
                });
            } else {
                throw new Error('Could not load detail map, no coordinates or address available');
            } // end if
        } else {
            that._loadDetailDeferred(result);
        } // end if
        //that._initDetailData(result);
    },
    _loadDetailDeferred: function(result) {
        var that = this;
        var deferredMapLoader = $.Deferred(function(defer) {
            that._initDetailMap(result, defer);
        });
        var deferredDataLoader = $.Deferred(function(defer) {
            that._initDetailData(result, defer);
        });
        $.when(deferredMapLoader, deferredDataLoader).done(function() {
            var offset = 0.00;
            var dataHeight = $(".detail-data > table > tbody").height();
            var mapHeight = $("#search-results .map-canvas").height();
            if (dataHeight > mapHeight) {
                $("#search-results .map-canvas").css({
                    height: dataHeight,
                });
                offset = (dataHeight - mapHeight) / 2;
            } // end if
            if (offset > 0.00) {
                that.di.detailGoogleMap.map.panBy(0, offset * -1);
            } // end if
        });
        if (result.origin) {
            that._$detail.find('.detail-header hr').before('<img height="31" alt="Origin '+result.origin+'" class="result-origin-icon" src="/assets/origin-'+result.origin+'.png">');
        } // end if
    },
    _initDetailMap: function(data, defer) {
        var that = this;
        new VenueDetailGoogleMap(that.di, {latitude: data.geometry.lat, longitude: data.geometry.lng}, that._$detail.find('.map-canvas').attr('id'),
        14,
        function() {
            defer.resolve();
            var location = that.di.locator.getLocation();
            if (location && that.di.detailGoogleMap) {
                that.di.detailGoogleMap.addRoute(
                    {latitude: location.lat, longitude: location.lng},
                    {latitude: data.geometry.lat, longitude: data.geometry.lng},
                    'WALKING');
                } // end if

            });
        },
        _initDetailData: function(data, defer) {
            var that = this;
            that._$detail.find('.detail-header-name').text(data.name);

            if (data.origin && data.id) {
                var url = that.buildDetailUrl(data);

                $.ajax({
                    url: url,
                    method: 'GET',
                    success: function(response) {
                        if (response) {
                            $(".detail-wrapper .detail-body .detail-data").html(response);
                            $('.social-likes').socialLikes();
                            defer.resolve();
                        } // end if
                    },
                    error: defer.reject,
                });
            }

            //console.log('init detail data...');
        },
        _buildDetailRow: function() {
            var that = this;
            var $div = $(
                '<div class="col-lg-12 detail-wrapper">' +
                '  <div class="col-lg-12 detail-header">' +
                '    <hr>' +
                '  </div>' +
                '  <div class="col-lg-12 detail-body">' +
                '    <div class="detail-data col-lg-4">' +
                '      <div class="cube-spinner"><div class="cube1"></div><div class="cube2"></div></div>' +
                '    </div>' +
                '    <div class="map-canvas col-lg-8" id="' + that.di.mixin.generateRandomHash() + '"></div>' +
                '  </div>' +
                '  <div class="col-lg-12 detail-footer">' +
                '    <hr>' +
                '  </div>' +
                '</div>'
            );
            return $div;
        },
        _close: function() {
            var that = this;
            if (that.isOpen() && that._$detail) {
                that._$detail.removeClass('active');
                that._$cube.removeClass('active');
                $(".detail-wrapper").slideUp('fast').remove();
                that._setCloseState();
            } // end if
        },
        _closeOthers: function() {
            var that = this;
            $(".detail-wrapper").slideUp('fast').remove();
            $(".result-box[data-cube-rel]").removeAttr('data-cube-rel').attr('data-cube-open', 'false');
        },
        setOpenState: function() {
            var that = this;
            that._$cube.attr('data-cube-open', 'true');
        },
        _setCloseState: function() {
            var that = this;
            that._$cube.attr('data-cube-open', 'false');
        },
        isOpen: function() {
            var that = this;
            return (that._$cube.attr('data-cube-open') == 'true');
        },
        destroy: function() {
            var that = this;
            that._close();
            that.di.detailGoogleMap = null;
        },
        /**
        * @static
        * @param  {object} data
        * @return {String} relative url
        */
        buildDetailUrl: function(data, that) {
            that = that || this;
            var loc = that.di.locator.getLocation();
            var ll = loc.lat. toFixed(7).toString() + ',' + loc.lng. toFixed(7).toString();
            var name = encodeURIComponent(data.ascii_name ? data.ascii_name.toString() : 'show');
            var origin = encodeURIComponent(data.origin.toString());
            var id = encodeURIComponent(data.id.toString());

            if ( ! that.di.mixin.isAscii(data.id.toString())) {
                url = '/detail/' + name + '/' + origin + '/@/' + ll + '?id=' + id;
            } else {
                url = '/detail/' + name + '/' + id + '/' + origin + '/@/' + ll;
            } // end if
            return url;
        } // end method
    }; // end prototype
