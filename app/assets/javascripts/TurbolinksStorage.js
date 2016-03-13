/**
* @author PN @since 2015-05-02
*/
var TurbolinksStorage = function() {
    this._storageKey = '_navihub_turbolinks_storage';
    this._storage = null;
    this._init();
}; // end func

TurbolinksStorage.prototype = {

    _init: function() {
        var that = this;
        if ( typeof window[that._storageKey] === 'undefined' ) {
            window[that._storageKey] = {};
        } // end if
        that._storage = window[that._storageKey];
    }, // end method

    get: function(k) {
        var that = this;
        if ( typeof k != 'undefined' ) {
            return ( typeof that._storage[k] != 'undefined' ? that._storage[k] : null );
        } else {
            return that._storage;
        } // end if
    }, // end method

    set: function(k, v) {
        var that = this;
        that._storage[k] = v;
        that.save();
    }, // end method

    save: function() {
        return true;
    }, // end method

}; // end prototype
