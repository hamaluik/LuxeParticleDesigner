package ui;

import luxe.options.SpriteOptions;
import luxe.Rectangle;
import phoenix.Texture;
import luxe.Text;

typedef ButtonOptions = {
	> SpriteOptions,

	// the layout of the slider in the image texture, in pixels
	var normalTexture:Texture;
	@:optional var hoverTexture:Texture;
	@:optional var pressedTexture:Texture;

	var onclicked:Void->Void;

	// the location of the nineslice slices in pixels
	var top : Float;
	var left : Float;
	var right : Float;
	var bottom : Float;

	var text:Text;

} // ButtonOptions