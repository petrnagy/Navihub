/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var SearchAjaxLoader = function(di) {
    this.di = di;
}; // end func

SearchAjaxLoader.prototype = {

    load: function() {
        var that = this;
        that.di.loader.show();
        var url = window.location.pathname.toString().replace('/search/', '/lazy-search/');
        if ( window.location.search ) {
            url += window.location.search.toString();
        } // end if
        $.get(url, function(html){
            $('#search-results-lazy').replaceWith(html);
            that.init();
            that.di.loader.hide();
        });
    }, // end method

    init: function() {
        var that = this;
        that.di.search = new Search(21, that.di); // 21 results per page
        that.di.btn = new NextButton(that.di);
        that.di.searchResult = new SearchResult(that.di);
        that.di.lazyLoader = new SearchResultsLazyLoader(that.di);
        that.di.lazyLoader.lazyLoad();
        that.di.lazyLoader.initEllipsis();
    }, // end method

}; // end prototype
