/**
* @author PN @since 2014-10-12
* @static
*/
Mixin = {
    generateRandomHash: function(length) {
        length = length || 32;
        return (Math.random() + 1).toString(36).substring(0, length).replace(/[^\w\d]/, '_');
    },
    isAscii: function(str) {
        return  /^[\x00-\x7F]+$/.test(str);
    },
    clone: function (obj){
        return $.extend({}, obj);
    },
    validateEmail: function (email) {
        var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        return re.test(email);
    },
    generateFunctionName: function(str) {
        return str.replace(/[^\d|\w|\_]/g, '_');
    },
};
