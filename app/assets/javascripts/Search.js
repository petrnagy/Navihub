/**
* @author PN @since 2014-08-30
*/
var Search = function(step) {
  this.step = step;
  this.$form = $("#search-form");
  this.defaults = {
    sort: 'distance-asc',
    offset: 0,
    radius: 10000,
  };
  // order matters !
  this.interests = ['term', 'radius', 'sort', 'offset'];
  if ( this.$form.length ) {
    this._init();
  } else {
    throw new Error();
  } // end if
} // end func

Search.prototype = {

  _init: function() {
    this._bindSubmit();
    this._bindChange();
  },

  _bindSubmit: function() {
    var that = this;
    that.$form.submit(function(e) {
      e.preventDefault();
      that.ajaxSubmit();
      return false;
    });
  }, // end method

  _bindChange: function() {
    var that = this;
    that.$form.find("input[type='text'], select").change(function() {
      that.$form.find("[name='search[offset]']").val(0);
    });
  }, // end method

  ajaxSubmit: function(append) {
    var that = this;
    var values = that.getValues();
    if ( values['term'].length ) {
      var url = that.buildUrl(values);
      if ( url && url != window.location.href ) {
        that.pushUrl(url);
        that.lock();
        Spinner.show();
        $.ajax({
          url: url,
          data: { append: Number( typeof append != 'undefined' && append ) },
          success: function(data) {
            if ( append ) {
              $("#search-results").append(data);
            } else {
              $("#search-results").html(data);
            } // end if
            Spinner.hide();
            that.unlock();
          }, // end func
          error: function() {
            //window.location.reload();
            Spinner.hide();
            that.unlock();
          } // end func
        });
      } // end if  
    } // end if
  }, // end method

  updateUrl: function() {
    var that = this;
    that.pushUrl(that.buildUrl(that.getValues()));
  }, // end method

  getValues: function() {
    var that = this;
    return {
      term: that.$form.find("[name='search[term]']").val().trim(),
      radius: parseInt(that.$form.find("[name='search[radius]'] option:selected").val(), 10),
      sort: that.$form.find("[name='search[sort]'] option:selected").val(),
      offset: parseInt(that.$form.find("[name='search[offset]']").val(), 10),
    };
  }, // end method

  buildUrl: function(values) {
    var that = this;
    var url = '';
    if ( window.location.origin ) {
      url += window.location.origin;
    } else {
      url += 'http://' + window.location.host;
    } // end if
    url += '/search';
    $.each(that.interests, function(k, v) {
      url += '/' + encodeURIComponent( typeof values[v] != 'undefined' && values[v] ? values[v] : that.defaults[v] );
    });
    return url;

  }, // end method

  pushUrl: function(url) {
    var that = this;
    try {
      window.history.pushState(null, null, url)
      return true;
    } catch (e) { // IE9 and lower
      return false;
    } // end try-catch
  }, // end method

  lock: function() {
    var that = this;
    that.$form.find('input, select, option, button').prop('disabled', true);
  }, // end method

  unlock: function() {
    var that = this;
    that.$form.find('input, select, option, button').prop('disabled', false);
  }, // end method

} // end prototype