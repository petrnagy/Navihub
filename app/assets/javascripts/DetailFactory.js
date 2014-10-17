/**
 * @author PN @since 2014-10-11
 * @static
 */
DetailFactory = {
    _prev: null,
    activate: function($button, di) {
        if ($button.length) {
            var self = DetailFactory;
            var $cube = new Detail($button.closest('.result-box'), di);
            if (self._prev !== null) {
                self._prev.destroy();
            } // end if
            self._prev = $cube;
            $cube.switch();
        } // end if
    },
}