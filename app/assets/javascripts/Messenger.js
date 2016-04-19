/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var Messenger = function(di) {
    this.di = di;
}; // end func

Messenger.prototype = {

    message: function(title, msg, opts) {
        var that = this;
        that._message(title, msg, 'message', 'message', opts);
    }, // end method

    success: function(title, msg, opts) {
        var that = this;
        that._message(title, msg, 'success', 'success', opts);
    }, // end method

    warning: function(title, msg, opts) {
        var that = this;
        that._message(title, msg, 'warning', 'warning', opts);
    }, // end method

    error: function(title, msg, opts) {
        var that = this;
        that._message(title, msg, 'error', 'error', opts);
    }, // end method

    _message: function(title, msg, type, cls, opts) {
        var that = this;
        type = 'type-' + (type || 'default');
        cls = 'cls-' + (cls || 'default');
        opts = ( typeof opts == 'object' ? opts : {} );
        var options = $.extend(opts, {
            html: '<p class="message-title text-center ' + type + ' ' + cls + '">' + title.toString() + '</p><p class="message-txt text-center ' + type + ' ' + cls + '">' + msg.toString() + '</p>',
            width: '400px',
            height: '200px',
            opacity: 0.5,
            maxWidth:'95%',
            maxHeight:'95%'
        });
        $.colorbox(options);
    }, // end method

}; // end prototype
