/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

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
            var wasOpen = false;
            if (self._prev !== null) {
                wasOpen = (self._prev.isOpen() && self._prev.id == $cube.id);
                self._prev.destroy();
            } // end if
            self._prev = $cube;
            if (wasOpen) {
                $cube.setOpenState();
                wasOpen = false;
            } // end if
            $cube.switch();
        } // end if
    },
}
