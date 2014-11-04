/**
 * @author PN @since 2014-09-28
 */
var Detail = function($cube, di) {
    if ($cube.length) {
        this.di = di;
        this._$cube = $cube;
        this._$detail = null;
        this._columns = 3;
        this._init();
    } // end if
} // end func

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
            that._loadDetail();
        } // end if
    },
    _open: function() {
        var that = this;
        var hash = Mixin.generateRandomHash(20);
        that._$detail = that._buildDetailRow();
        that._$detail.attr('data-cube-rel', hash);
        that._$cube.attr('data-cube-rel', hash);
        var prevCount = that._$cube.prevAll().length;
        var offset = that._columns - (prevCount % that._columns);
        var $nextAll = that._$cube.nextAll();
        var index = null;
        if ($nextAll.length >= offset) {
            index = offset - 2;
        } else {
            index = $nextAll.length - 2;
        } // end if
        var $next = $nextAll.eq(index < 0 ? 0 : index);
        if (index >= 0) {
            $next.after(that._$detail);
        } else {
            $next.before(that._$detail);
        } // end if
        that._$detail.addClass('active');
        that._$cube.addClass('active');
        that.setOpenState();
    },
    _loadDetail: function() {
        var that = this;
        var jsonAttr = that._$cube.attr('data-result-json');
        try {
            var result = JSON.parse(jsonAttr);
        } catch (e) {
            return that._processDetailError(e);
        } // end try-catch
        if (result.geometry.lat === null || result.geometry.lng === null) {
            try {
                if (result.address) {
                    var geocode = new GoogleGeocode(result.address);
                    geocode.load(function(coords) {
                        if (coords !== null) {
                            result.geometry = coords;
                            that._initDetailMap(result);
                        } else {
                            throw new Error('Could not load detail map, geocode failed');
                        } // end if
                    });
                } else {
                    throw new Error('Could not load detail map, no coordinates or address available');
                } // end if   
            } catch (e) {
                return that._processDetailError(e);
            } // end try-catch
        } else {
            that._initDetailMap(result);
        } // end if
        that._initDetailData(result);
    },
    _initDetailMap: function(data) {
        var that = this;
        new GoogleMap(
                {latitude: data.geometry.lat, longitude: data.geometry.lng},
        that._$detail.find('.map-canvas').attr('id'),
                14,
                function() {
                    var location = that.di.locator.getLocation();
                    if (location && detailGoogleMap) {
                        detailGoogleMap.addRoute(
                                {latitude: location.lat, longitude: location.lng},
                        {latitude: data.geometry.lat, longitude: data.geometry.lng},
                        'WALKING');
                    } // end if
                });
    },
    _initDetailData: function(data) {
        var that = this;
        that._$detail.find('.detail-header-name').text(data.name);

        if (data.origin && data.id) {
            var url = '';
            if (!Mixin.isAscii(data.id.toString())) {
                url = '/detail/' + (data.ascii_name ? data.ascii_name.toString() : Mixin.generateRandomHash(5)) + '/' + data.origin.toString() + '?id=' + data.id.toString();
            } else {
                url = '/detail/' + (data.ascii_name ? data.ascii_name.toString() : Mixin.generateRandomHash(5)) + '/' + data.id.toString() + '/' + data.origin.toString();
            } // end if

            $.ajax({
                url: url,
                method: 'get',
                success: function(response) {
                    if (response) {
                        $(".detail-wrapper .detail-body .detail-data").html(response);
                    } // end if
                },
            });
        }

        //console.log('init detail data...');
    },
    _buildDetailRow: function() {
        var that = this;
        var $div = $(
                '<div class="col-lg-12 detail-wrapper">' +
                '  <div class="col-lg-12 detail-header">' +
                '    <h3>Details - <span class="detail-header-name"></span></h3>' +
                '    <hr>' +
                '  </div>' +
                '  <div class="col-lg-12 detail-body">' +
                '    <div class="detail-data col-lg-4">' +
                '      <div class="cube-spinner"><div class="cube1"></div><div class="cube2"></div></div>' +
                '    </div>' +
                '    <div class="map-canvas col-lg-8" id="' + Mixin.generateRandomHash() + '"></div>' +
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
        detailGoogleMap = null;
    },
} // end prototype