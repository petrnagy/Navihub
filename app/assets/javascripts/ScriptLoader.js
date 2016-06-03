/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

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
        var lambdaData = that._prepareLambdaFunction(script, param);
        var lambda = ( lambdaData !== null ? lambdaData.name : '' );

        var storageKey = 'javascripts';
        var loadedScripts = that.di.turbolinksStorage.get(storageKey);
        loadedScripts = ( null === loadedScripts ? [] : loadedScripts );
        if ( loadedScripts[script] === undefined ) { // adding script to queue
            loadedScripts[script] = false; // false = "loading"
            that.di.turbolinksStorage.set(storageKey, loadedScripts);
            $.getScript(script + lambda, function(){
                var loadedScripts = that.di.turbolinksStorage.get(storageKey);
                loadedScripts[script] = true;
                that.di.turbolinksStorage.set(storageKey, loadedScripts);
                callback();
            });
        } else { // script already in queue
            var interval = setInterval(function(){
                var loadedScripts = that.di.turbolinksStorage.get(storageKey);
                if ( loadedScripts[script] === true ) {
                    clearInterval(interval);
                    if ( lambda.length ) {
                        eval(lambda + '()');
                    } // end if
                    callback();
                } // end if
            }, 1000);
        } // end if
    }, // end method

    _prepareLambdaFunction: function(script, func) {
        var that = this;
        if ( ! func ) {
            return null;
        } else {
            return that._createLambdaFunction(script, func);
        } // end if
    }, // end method

    _createLambdaFunction: function(script, func) {
        var that = this;
        var fname = Mixin.generateFunctionName(script);
        var lambdaName = 'lambda_' + fname;
        var lambdaQueue = 'lambda_queue_' + fname;

        if ( typeof window[lambdaName] === 'function' ) {
            window[lambdaQueue].push(func + '()');
            return { name: func };
        } else {
            window[lambdaQueue] = [];
            window[lambdaQueue].push(func + '()');
            var lambdaEval = 'window.' + lambdaName + ' = function() {\n';
            lambdaEval += '  $.each(window["' + lambdaQueue + '"], function(key, val) {\n';
            lambdaEval += '    eval(val);\n';
            lambdaEval += '  }); // end foreach\n';
            lambdaEval += '};';

            eval(lambdaEval);
            return { name: lambdaName, queue: lambdaQueue };
        } // end if
    }, // end method

}; // end prototype
