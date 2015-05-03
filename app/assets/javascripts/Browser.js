/**
* @author PN @since 2015-05-01
*/
Browser = {

  /**
   * @static
   * @return Boolean
   */
  isExplorer: function (){
      return ( navigator.userAgent.indexOf('MSIE') > -1 );
  }, // end method

  /**
   * @static
   * @return Boolean
   */
  isChrome: function (){
      var isChrome = ( navigator.userAgent.indexOf('Chrome') > -1 );
      return ( isChrome && ! Browser.isOpera() );
  }, // end method

  /**
   * @static
   * @return Boolean
   */
  isSafari: function (){
      var isSafari = ( navigator.userAgent.indexOf("Safari") > -1 );
      return ( isSafari && ! Browser.isChrome() );
  }, // end method

  /**
   * @static
   * @return Boolean
   */
  isFirefox: function (){
      return ( navigator.userAgent.indexOf('Firefox') > -1 );
  }, // end method

  /**
   * @static
   * @return Boolean
   */
  isOpera: function (){
      return ( navigator.userAgent.toLowerCase().indexOf("op") > -1 );
  }, // end func

};
