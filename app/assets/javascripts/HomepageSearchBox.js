/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

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
            that._loadHiresBackground();
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

        document.getElementById("hp-outer").style.height = '';
    }, // end method

    _recalculate: function() {
        var that = this;
        //var footerMargin = parseInt($('footer').css('margin-top'), 10);
        var footerMargin = 0;
        var yieldMargin = parseInt($('#yield').css('margin-top'), 10);
        var menuHeight = $('.navbar-fixed-top').height();
        var menuBottomMargin = parseInt($('.navbar-fixed-top').css('margin-bottom'), 10);
        var windowHeight = $(window).height();
        var magic = -12;
        var breakPoint = 316; // breakpoint from which we set padding instead of height
        var navidogTopMargin = parseInt($('section#navidog').css('margin-top'), 10);

        if ($(window).width() < 992) magic = 1;
        //if ($(window).width() < 640) magic = 40;

        var pixelsToFill = windowHeight - menuHeight - footerMargin - yieldMargin - magic - navidogTopMargin;

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

    _loadHiresBackground: function() {
        var that = this;
        var $body = $('body.c-homepage.a-index');
        if ( $body.length ) {
            var bg = $body.css('background');
            bg = bg.match(/https?:\/\/[^"]*/);
            if ( bg[0] ) {
                var src = bg[0].replace('lowres', 'hires');
                var $img = $( '<img src="' + src + '">' );
                $img.bind('load', function() {
                    //$body.css('background', 'url("'+src+'")');
                    var final = 'rgba(0, 0, 0, 0) url("'+src+'") no-repeat scroll 50% 0% / 100% padding-box border-box';
                    $body.css('background', final);
                } );
            } // end if
        } // end if
    }, // end method

}; // end prototype
