var MarkerMenu = function(di) {
    this.di = di;
    this.menu = '#menu-loc';
    this.marker = '#marker-menu';
    this._init();
}; // end func

MarkerMenu.prototype = {

    _init: function() {
        this._initMarker();
    }, // end method

    _initMarker: function() {
        var that = this;
        var $marker = $(that.marker);
        var $menu = $(that.menu);

        $marker.find('a').click(function(e) {
            e.preventDefault();
            if ($menu.is(':visible')) {
                that.close();
            } else {
                that.di.burger.close();
                that.open();
            } // end if-else
            return false;
        });
    }, // end method

    active: function() {
        var that = this;
        var $marker = $(that.marker);
        return $marker.is(':visible');
    }, // end method

    open: function() {
        var that = this;
        if ( that.active() ) {
            var $menu = $(that.menu);
            $menu.slideDown();
        } // end if
    }, // end method

    close: function() {
        var that = this;
        if ( that.active() ) {
            var $menu = $(that.menu);
            $menu.slideUp();
        } // end if
    }, // end method

}; // end prototype
