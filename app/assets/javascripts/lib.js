/**
 * @author PN @since 2015-05-02
 */

 String.prototype.hashCode = function() {
   var hash = 0, i, chr, len;
   if (this.length === 0) return hash;
   for (i = 0, len = this.length; i < len; i++) {
     chr   = this.charCodeAt(i);
     hash  = ((hash << 5) - hash) + chr;
     hash |= 0; // Convert to 32bit integer
   }
   return hash;
 };

 function arrayUnique (a) {
     return a.reduce(function(p, c) {
         if (p.indexOf(c) < 0) p.push(c);
         return p;
     }, []);
 }

 var delay = (function(){
   var timer = 0;
   return function(callback, ms){
     clearTimeout (timer);
     timer = setTimeout(callback, ms);
   };
 })();

 /**
 * @returns {String}
 * @author PN @since 2013-09-29
 */
 function uniqueid() {
     return new Date().getTime() + '-' + Math.floor( 1 + Math.random() * 100 );
 } // end func
