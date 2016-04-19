/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

/**
* @author PN @since 2014-08-30
*/
var NextButton = function(di) {
  this.di = di;
  this.search = di.search;
  this._init();
}; // end func

NextButton.prototype = {

  _init: function() {
    this._initButtons();
  },

  _initButtons: function() {
    var that = this;
    $(document).delegate("#yield .load-more button", 'click', function() {
      if ( $(this).prop('disabled') ) { return; } // end if
      var offset = parseInt($("#yield .result-box").length, 10);
      if ( ! isNaN(offset) ) {
        that.search.$form.find("[name='search[offset]']").val(offset);
        var values = $.extend(JSON.parse($(this).attr('data-params')), { offset: offset });
        that.search.ajaxSubmit(true, values);
        $(this).prop('disabled', true);
      } else {

      } // end if
    });
  }, // end method

}; // end prototype
