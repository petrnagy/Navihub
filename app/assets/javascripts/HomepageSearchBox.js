var HomepageSearchBox = function(di) {
    this.di = di;
    this.id = '#search-input-wrapper';
    this._init();
}; // end func

HomepageSearchBox.prototype = {

    _init: function() {
        var that = this;
        var $elem = $('#search-input-wrapper');
        if ( $elem.length ) {
            this._initResizer();
        } // end if
    }, // end method

    _initResizer: function() {
      var that = this;
      // TODO: eventy resize a changerotation zmenit velikost (css) search boxiku
    }, // end method

}; // end prototype
