/**
 * @author PN @since 2014-10-12
 * @static
 */
Mixin = {
    generateRandomHash: function(length) {
        var length = length || 32;
        return (Math.random() + 1).toString(36).substring(0, length).replace(/[^\w\d]/, '_');
    },
}