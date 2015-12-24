var SearchResultsLazyLoader = function(di) {
    this.di = di;
    this._init();
}; // end func

SearchResultsLazyLoader.prototype = {

    _init: function() {
        this._initSearchResultsStaticImagesLazyLoading();
    }, // end method

    _initSearchResultsStaticImagesLazyLoading: function() {
      var that = this;
      $(window).scroll(function(e) { that.lazyLoadSearchResultsImages(); });
      $(window).resize(function(e) { that.lazyLoadSearchResultsImages(); });
      $(window).on("orientationchange",function() { that.lazyLoadSearchResultsImages(); });
    }, // end method

    lazyLoadSearchResultsImages: function() {
      var that = this;
      $set = $('#yield #search-results .map-wrapper img[lazysrc]:in-viewport');
      $set.each(function(){
         $(this).attr('src', $(this).attr('lazysrc'));
         $(this).removeAttr('lazysrc');
      });
    }, // end method

}; // end prototype
