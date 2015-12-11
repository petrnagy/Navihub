var ScriptLoader = function(di) {
    this.di = di;
}; // end func

ScriptLoader.prototype = {

    /**
    * @param {String} string
    * @param {String} param
    * @param {function} callback
    * @returns {void}
    * @access public
    * @author PN @since 2014-10-07
    */
    load: function(script, param, callback) {
        var that = this;

        callback = ( typeof callback == 'function' ? callback : function(){} );
        param = ( typeof param == 'string' ? param : false );

        var storageKey = 'javascripts';
        var loadedScripts = that.di.turbolinksStorage.get(storageKey);
        loadedScripts = ( null === loadedScripts ? [] : loadedScripts );

        if ( loadedScripts.indexOf(script) >= 0 ) {
            if ( param.length ) {
                eval(param + '()');
            } // end if
            callback();
        } else {
            loadedScripts.push(script);
            that.di.turbolinksStorage.set(storageKey, loadedScripts);
            $.getScript(script + (param || ''), callback);
        } // end if
    }, // end method

}; // end prototype
