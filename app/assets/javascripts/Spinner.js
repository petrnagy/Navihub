/**
* @author PN @since 2014-08-30
*/
Spinner = {

  DEFAULT_DELAY: 'slow',

  show: function(delay) {
    $("#spinner").fadeIn( delay = Spinner._getDelay(delay) );
  },

  hide: function(delay) {
    $("#spinner").fadeOut( delay = Spinner._getDelay(delay) );
  },

  _getDelay: function (delay){
    return ( typeof delay == 'undefined' ? Spinner.DEFAULT_DELAY : delay );
  }
};
