package ui;

import luxe.Input;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.utils.Maths;
import luxe.Vector;
import luxe.Visual;
import luxe.NineSlice;
import luxe.Text;
import phoenix.Batcher;
import phoenix.Texture;
import phoenix.geometry.Vertex;
import phoenix.geometry.QuadPackGeometry;
import phoenix.geometry.CompositeGeometry;
import phoenix.geometry.QuadGeometry;
import phoenix.geometry.TextureCoord;

import ui.ButtonOptions;

enum ButtonState {
	NORMAL;
	HOVERING;
	PRESSING;
}

class Button extends Visual {
	var _geometry:NineSlice;
	var normalTexture:Texture;
	var hoverTexture:Texture;
	var pressedTexture:Texture;

	var text:Text;

	var onclicked:Void->Void;

	var hovering:Bool = false;
	var pressing:Bool = false;
	var buttonState:ButtonState = ButtonState.NORMAL;
	var bounds:Rectangle;

	public function new(_options:ButtonOptions) {
		if(_options == null) {
			throw "Need none-null options for slider!";
		}

		// we'll handle these for ourselves, thank-you-very-much
		_options.no_geometry = true;

		// make sure it has a batcher
		if(_options.batcher == null) {
			_options.batcher = Luxe.renderer.batcher;
		}

		// misc. visual options
		super(_options);

		// store the click callback
		onclicked = _options.onclicked;

		// store the textures
		normalTexture = _options.normalTexture;
		hoverTexture = _options.hoverTexture;
		pressedTexture = _options.pressedTexture;

		// autosize the button to fully encompass the text
		size = _options.text.font.dimensions_of(_options.text.text, _options.text.point_size, size).add_xyz(16, 16);

		// create the geometry
		pos.add_xyz(size.x / -2, size.y / -2);
		_geometry = new NineSlice({
			texture: normalTexture,
			top: _options.top,
			left: _options.left,
			right: _options.right,
			bottom: _options.bottom,
			depth: _options.depth
		});
		_geometry.create(pos, size.x, size.y);

		// setup the text
		text = _options.text;
		text.align = TextAlign.center;
		text.align_vertical = TextAlign.center;
		text.pos = pos.clone();
		text.pos.add_xyz(size.x / 2, size.y / 2);
		text.depth = _geometry.depth + 1;

		bounds = new Rectangle(pos.x, pos.y, size.x, size.y);
	}

	override function onmousemove(e:MouseEvent) {
		hovering = bounds.point_inside(e.pos);
		updateState();
	}

	override function onmousedown(e:MouseEvent) {
		if(hovering) pressing = true;
		else pressing = false;
		updateState();
	}

	override function onmouseup(e:MouseEvent) {
		if(pressing) onclicked();
		pressing = false;
		updateState();
	}

	function updateState() {
		if(pressing) {
			buttonState = ButtonState.PRESSING;
		}
		else if(hovering) {
			buttonState = ButtonState.HOVERING;
		}
		else {
			buttonState = ButtonState.NORMAL;
		}

		switch(buttonState) {
			case ButtonState.NORMAL:
				if(_geometry.texture != normalTexture) _geometry.texture = normalTexture;
			case ButtonState.HOVERING:
				if(_geometry.texture != hoverTexture) _geometry.texture = hoverTexture;
			case ButtonState.PRESSING:
				if(_geometry.texture != pressedTexture) _geometry.texture = pressedTexture;
		}
	}
}