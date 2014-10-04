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
//= require turbolinks
//= require Locator
//= require_tree .

$.ajaxSetup({
  cache: false,
  contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
});

new Locator();

if ( $("#search-form").length ) {
    search = new Search(21);
    btn = new NextButton(search);
} // end if

if ( $("#search-input").length ) {
    input = new Input(21);
} // end if