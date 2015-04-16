package ;

import luxe.Text;
import luxe.Color;
import luxe.Vector;
import luxe.Rectangle;
import phoenix.Texture;
import ui.Slider;
using NumberFormat;

class ParticlePropertyControl {
	var slider:Slider;
	var title:Text;
	var valueDisplay:Text;

	var name:String = "";
	var min:Float;
	var max:Float;
	var initial:Float;
	var updateParticles:Float->Void;

	static var nextX:Float = 8;
	static var nextY:Float = 8;
	public static var uiTexture:Texture;

	public function new(name:String, min:Float, max:Float, initial:Float, updateParticles:Float->Void) {
		this.name = name;
		this.min = min;
		this.max = max;
		this.initial = initial;
		this.updateParticles = updateParticles;

		title = new Text({
			pos: new Vector(nextX, nextY),
			align: TextAlign.left,
			align_vertical: TextAlign.top,
			text: name,
			color: new Color(1, 1, 1, 1),
			point_size: 12
			});

		valueDisplay = new Text({
			pos: new Vector(nextX + 134, nextY + 25),
			align: TextAlign.left,
			align_vertical: TextAlign.center,
			text: '0',
			color: new Color(1, 1, 1, 1),
			point_size: 12
			});

		slider = new Slider({
			texture: uiTexture,
			pos: new Vector(nextX, nextY + 26),
			size: new Vector(128, 8),
			leftCap: new Rectangle(0, 1, 7, 8),
			background: new Rectangle(8, 3, 24, 4),
			rightCap: new Rectangle(33, 1, 4, 8),
			handle: new Rectangle(40, 0, 5, 10),
			initialValue: (initial - min) / (max - min)
			});
		slider.addValueEventListener(valueChanged);

		nextY += 40;
		if(nextY >= Luxe.screen.h - 40) {
			nextY = 8;
			nextX = Luxe.screen.w - 172;
		}
	}

	// todo: adjust particle callback
	function valueChanged(_v:Float) {
		_v = _v * (max - min) + min;
		valueDisplay.text = _v.toFixed(2);
		try {
			updateParticles(_v);
		}
		catch(e:Dynamic) {}
	}
}