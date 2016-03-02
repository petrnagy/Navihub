/**
 * @author PN @since 2015-05-02
 */
var AddressFormatter = function(di) {
  this.di = di;
}; // end func

AddressFormatter.prototype = {

    formatGoogleMapsGeolocatorResults: function(results) {
      var that = this;
      var o = '';
      $.each(results, function(key, result) {
        if ( typeof result == 'object' && result.formatted_address ) {
          o = result.formatted_address;
          return false;
        } // end if
      }); // end foreach
      return o;
    }, // end method

}; // end prototype
