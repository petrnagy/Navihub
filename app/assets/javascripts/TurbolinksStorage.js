/**
 * @author PN @since 2015-05-02
 */
var TurbolinksStorage = function() {
    this._element = 'html';
    this._$element = $(this._element);
    this._attribute = 'data-turbolinks-storage';
    this._storage = {};

    if ( 1 === this._$element.length ) {
      this._init();
    } else {
      throw new Error("Storage element not found or found multiple times: " + this._element.toString());
    } // end if
}; // end func

TurbolinksStorage.prototype = {

    _init: function() {
      var that = this;
      var storage = that._$element.attr(that._attribute);
      if ( storage ) {
        that._storage = JSON.parse(storage);
      } // end if
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
      var that = this;
      that._$element.attr(that._attribute, JSON.stringify(that._storage));
    }, // end method

}; // end prototype
