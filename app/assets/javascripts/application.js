// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require turbolinks
//= require Locator
//= require_tree .

$.cookie.json = true;

$.ajaxSetup({
  cache: false,
  contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
});

var DI = {};

DI.locator = new Locator();

if ( $("#search-form").length ) {
    DI.search = new Search(21); // 21 results per page
    DI.btn = new NextButton(DI.search);
    $(document).delegate('.btn-detail', 'click', function(e){
        e.preventDefault();
        DetailFactory.activate($(this), DI);
        return false;
    });
} // end if

if ( $("#search-input").length ) {
    DI.input = new Input(21);
} // end if