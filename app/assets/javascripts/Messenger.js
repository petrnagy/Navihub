var Messenger = function(di) {
    this.di = di;
}; // end func

Messenger.prototype = {

    message: function(title, txt) {
      var that = this;
      $.colorbox({
          html: '<p class="message-title text-center">' + title.toString() + '</p><p class="message-txt text-center">' + txt.toString() + '</p>',
          width: '400px',
          height: '200px',
          opacity: 0.5
      });
    }, // end method

}; // end prototype
