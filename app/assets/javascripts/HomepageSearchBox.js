var HomepageSearchBox = function(di) {
    this.di = di;
    this.id = '.hp-outer';
    this.wrapper = '#search-input-wrapper';
    this._originalPaddingTop = null;
    this._originalPaddingBottom = null;
    this._init();
}; // end func

HomepageSearchBox.prototype = {

    _init: function() {
        var that = this;
        var $elem = $(that.id);
        if ( $elem.length ) {
            that._initResizer();
            that._recalculate();
        } // end if
    }, // end method

    _initResizer: function() {
        var that = this;

        that._originalPaddingTop = parseInt($(that.wrapper).css('padding-top'), 10);
        that._originalPaddingBottom = parseInt($(that.wrapper).css('padding-bottom'), 10);

        $(window).resize(function(e){
            that._recalculate();
        });
        $(window).on("orientationchange",function(){
            that._recalculate();
        });

    }, // end method

    _recalculate: function() {
        var that = this;
        var footerMargin = parseInt($('footer').css('margin-top'), 10);
        var yieldMargin = parseInt($('#yield').css('margin-top'), 10);
        var menuHeight = $('.navbar-fixed-top').height();
        var windowHeight = $(window).height();
        var magic = 0;
        var breakPoint = 316;

        if ($(window).width() < 992) magic = 20;
        if ($(window).width() < 640) magic = 40;

        var pixelsToFill = windowHeight - menuHeight - footerMargin - yieldMargin - magic;

        if ( pixelsToFill > breakPoint ) {
            $(that.id).css({
                'height': pixelsToFill + 'px'
            });
            $(that.wrapper).css({
                'padding-top': that._originalPaddingTop + 'px',
                'padding-bottom': that._originalPaddingBottom + 'px',
            });
        } else {
            pixelsToFill = breakPoint - pixelsToFill;
            var top = that._originalPaddingTop - pixelsToFill / 2;
            var bottom = that._originalPaddingBottom - pixelsToFill / 2;
            top = ( top > 0 ? top : 0 );
            bottom = ( bottom > 0 ? bottom : 0 );

            $(that.id).css({
                'height': '0px'
            });
            $(that.wrapper).css({
                'padding-top': top + 'px',
                'padding-bottom': bottom + 'px',
            });
        }

    }, // end method

}; // end prototype
