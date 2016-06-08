/*
* This file is part of the Navihub project (http://www.navihub.net/)
* Copyright (c) 2013 Petr Nagy (http://www.petrnagy.cz/)
* See readme.txt for more informations
*/

var Ellipsis = function() {

}; // end func

Ellipsis.prototype = {

	do: function($set) {
		var that = this;
		$set.each(function() {
			var $this = $(this);
			var $i = $this.find('.results-icon');
			var iHtml = $i[0].outerHTML;
			var ellipsis = '... ';
			//var $parent = $this.parent();
			$this.css('max-height', '');
			var maxHeight = parseFloat($this.css('max-height'), 10);
			var txt = $this.text().trim().replace(/ +/, ' ').replace(ellipsis, '');
			var newTxt = txt;
			$this.css('max-height', 'initial');
			var x = txt.length;

			if ( $this.height() > maxHeight ) {
				while ( x > 0 ) { --x;
					newTxt = iHtml + txt.substring(0, x) + ellipsis;
					$this.html(newTxt);
					if ( $this.height() <= maxHeight ) {
						// $(window).resize(function(){ that.refresh($this); });
						// $(window).on("orientationchange", function() { that.refresh($this); });
						break;
					} // end if
				} // end while
			} else {
				$this.css('max-height', maxHeight.toString() + 'px');
			} // end if

		});
	}, // end method

	// refresh: function($elem) {
	// 	var that = this;
	// 	$elem.removeClass('dotted');
	// }, // end method

}; // end prototype
