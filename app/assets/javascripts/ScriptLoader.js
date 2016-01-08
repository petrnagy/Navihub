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
        var lambda = that._prepareLambdaFunction(script, param);

        var storageKey = 'javascripts';
        var loadedScripts = that.di.turbolinksStorage.get(storageKey);
        loadedScripts = ( null === loadedScripts ? [] : loadedScripts );

        console.log(loadedScripts.indexOf(script));

        if ( loadedScripts.indexOf(script) >= 0 ) {
            // FIXME: script muze byt v policku, ale nemusi byt nutne nacteny !
            // TODO: no, ted to mam v lambde, to je super... ale jeste tam musi byt nejaky priznak, zda se to jeste nacita...
            if ( lambda.length ) {
                eval(lambda + '()');
            } // end if
            callback();
        } else {
            loadedScripts.push(script);
            that.di.turbolinksStorage.set(storageKey, loadedScripts);
            $.getScript(script + lambda, callback);
        } // end if
    }, // end method

    _prepareLambdaFunction: function(script, func) {
        var that = this;
        if ( ! func ) {
            return '';
        } else {
            return that._createLambdaFunction(script, func);
        } // end if
    }, // end method

    _createLambdaFunction: function(script, func) {
        var that = this;
        var fname = Mixin.generateFunctionName(script);
        var lambdaName = 'lambda_' + fname;
        var lambdaQueue = 'lambda_queue_' + fname;

        if ( typeof lambdaName === 'function' ) {
            window[lambdaQueue].push(func + '()');
            return ''
        } else {
            window[lambdaQueue] = [];
            window[lambdaQueue].push(func + '()');

            var lambdaEval = 'function ' + lambdaName + '() {\n';
            lambdaEval += '  for (var i = 0; i < window[' + lambdaQueue + '].length; i++) {\n';
            lambdaEval += '    eval(window[' + lambdaQueue + '][i]);\n';
            lambdaEval += '  } // end for  ;\n';
            lambdaEval += '};';

            eval(lambdaEval);
            return lambdaName;
        } // end if
    }, // end method

}; // end prototype
