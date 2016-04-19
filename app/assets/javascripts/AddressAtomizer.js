/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
 * @author PN @since 2015-05-02
 */
var AddressAtomizer = function(di) {
  this.di = di;
  this._template = {
      country: null, country_short: null, city: null, city2: null, street1: null, street2: null
  };
}; // end func

AddressAtomizer.prototype = {

  atomizeGoogleMapsGeolocatorResults: function(results) {
    var that = this;
    var tpl = that.di.mixin.clone(that._template);
    $.each(results, function(key, result) {

      var missing = 0;
      $.each(tpl, function(key, item) {
        if ( null === item ) {
          ++missing;
        } // end if
      }); // end foreach

      if ( ! missing ) {
        return false;
      } // end if

      $.each(result.address_components, function(key, component) {

        if ( component.types.indexOf('country') >= 0 ) {
          if ( component.short_name && ! tpl.country_short ) {
            tpl.country_short = component.short_name;
          } // end if
          if ( component.long_name && ! tpl.country ) {
            tpl.country = component.long_name;
          } // end if
        } // end if

        if ( component.types.indexOf('route') >= 0 && ! tpl.street1 ) {
          tpl.street1 = component.long_name;
        } // end if

        if ( component.types.indexOf('locality') >= 0 && ! tpl.city ) {
          tpl.city = component.long_name;
        } // end if

      }); // end foreach
    }); // end foreach

    return tpl;
  }, // end method

}; // end prototype
