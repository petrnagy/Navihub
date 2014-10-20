/**
 * @author PN @since 2014-09-28
 */
var VenueDetail = function(di) {
    this.di = di;
    this._data = null;
    this._init();
} // end func

VenueDetail.prototype = {
    _init: function() {
        var that = this;
        that._data = that._loadDetailData();
        that._initDetailMap();
    },
    _initDetailMap: function() {
        var that = this;
        var interval = setInterval(function() {
            var location = that.di.locator.getLocation();
            if (location && typeof location.lat !== 'undefined' && typeof location.lng !== 'undefined') {
                clearInterval(interval);
                new GoogleMap({latitude: location.lat, longitude: location.lng}, 'map_canvas', 14, function() {
                    if (detailGoogleMap && that._data) {
                        detailGoogleMap.addRoute(
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
} // end prototype