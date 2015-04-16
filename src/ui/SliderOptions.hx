package ui;

import luxe.options.SpriteOptions;
import luxe.Rectangle;

typedef SliderOptions = {
	> SpriteOptions,

	// the layout of the slider in the image texture, in pixels
	var leftCap:Rectangle;
	var background:Rectangle;
	var rightCap:Rectangle;
	var handle:Rectangle;

	@:optional var initialValue:Float;

} // SliderOptions