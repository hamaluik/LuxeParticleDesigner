package ui;

import luxe.Input;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.utils.Maths;
import luxe.Vector;
import luxe.Visual;
import phoenix.Batcher;
import phoenix.geometry.Vertex;
import phoenix.geometry.QuadPackGeometry;
import phoenix.geometry.CompositeGeometry;
import phoenix.geometry.QuadGeometry;
import phoenix.geometry.TextureCoord;

import ui.SliderOptions;

typedef SliderPart = {
	var pos_rect:Rectangle;
	var uv_rect:Rectangle;
	var geometry_id:Int;
}

class Slider extends Visual {
	var leftCap:SliderPart;
	var background:SliderPart;
	var rightCap:SliderPart;
	var handle:SliderPart;

	var _geometry:QuadPackGeometry;

	@:isVar public var value(default, null):Float;
	private var valueNotifiers:Array<Float->Void> = new Array<Float->Void>();

	var mouseButtonDown:Bool = false;

	public function new(_options:SliderOptions) {
		if(_options == null) {
			throw "Need none-null options for slider!";
		}

		// we'll handle these for ourselves, thank-you-very-much
		_options.no_geometry = true;
		//_options.no_scene = true;

		// make sure it has a batcher
		if(_options.batcher == null) {
			_options.batcher = Luxe.renderer.batcher;
		}

		// misc. visual options
		super(_options);

		// store the parts
		leftCap = {
			pos_rect: new Rectangle(pos.x, pos.y - (_options.leftCap.h / 2), _options.leftCap.w, _options.leftCap.h),
			uv_rect: _options.leftCap,
			geometry_id: 0
		};
		background = {
			pos_rect: new Rectangle(pos.x + _options.leftCap.w, pos.y - (_options.background.h / 2), size.x - _options.leftCap.w - _options.rightCap.w, _options.background.h),
			uv_rect: _options.background,
			geometry_id: 0
		};
		rightCap = {
			pos_rect: new Rectangle(pos.x + size.x - _options.rightCap.w, pos.y - (_options.rightCap.h / 2), _options.rightCap.w, _options.rightCap.h),
			uv_rect: _options.rightCap,
			geometry_id: 0
		};
		handle = {
			pos_rect: new Rectangle(pos.x + _options.leftCap.w, pos.y - (_options.handle.h / 2), _options.handle.w, _options.handle.h),
			uv_rect: _options.handle,
			geometry_id: 0
		};

		// create the geometry
		_geometry = new QuadPackGeometry({
			texture: texture,
			color: color,
			depth: depth,
			group: group,
			visible: visible,
			batcher: _options.batcher
		});

		// add some things to the pack
		leftCap.geometry_id = _geometry.quad_add({
			x: leftCap.pos_rect.x,
			y: leftCap.pos_rect.y,
			w: leftCap.pos_rect.w,
			h: leftCap.pos_rect.h,
			uv: leftCap.uv_rect
		});

		background.geometry_id = _geometry.quad_add({
			x: background.pos_rect.x,
			y: background.pos_rect.y,
			w: background.pos_rect.w,
			h: background.pos_rect.h,
			uv: background.uv_rect
		});

		rightCap.geometry_id = _geometry.quad_add({
			x: rightCap.pos_rect.x,
			y: rightCap.pos_rect.y,
			w: rightCap.pos_rect.w,
			h: rightCap.pos_rect.h,
			uv: rightCap.uv_rect
		});

		handle.geometry_id = _geometry.quad_add({
			x: handle.pos_rect.x,
			y: handle.pos_rect.y,
			w: handle.pos_rect.w,
			h: handle.pos_rect.h,
			uv: handle.uv_rect
		});

		_geometry.id = "Slider" + _geometry.id;

		if(_options.initialValue != null) {
			value = _options.initialValue;

			var minX:Float = pos.x + leftCap.uv_rect.w;
			var maxX:Float = pos.x + size.x - rightCap.uv_rect.w - handle.uv_rect.w;
			handle.pos_rect.x = value * (maxX - minX) + minX;
			_geometry.quad_pos(handle.geometry_id, new Vector(handle.pos_rect.x, handle.pos_rect.y));
		}
		else {
			value = 0;
		}

		_listen(Luxe.Ev.mousedown, onmousedown, true);
	}

	private inline function point_in_handle(_p:Vector):Bool {
		return handle.pos_rect.point_inside(_p);
	}

	override public function onmousedown(event:MouseEvent) {

		var clickPos:Vector = Luxe.camera.screen_point_to_world(event.pos);
		if(point_in_handle(clickPos)) {
			mouseButtonDown = true;
		}
	}

	override public function onmouseup(event:MouseEvent) {
		mouseButtonDown = false;
	}

	override public function onmousemove(event:MouseEvent) {
		if(mouseButtonDown) {
			// get the new position
			var newPos:Vector = Luxe.camera.screen_point_to_world(event.pos).add_xyz(handle.uv_rect.w / -2, 0, 0);
			newPos.y = handle.pos_rect.y;

			// clamp it
			var minX:Float = pos.x + leftCap.uv_rect.w;
			var maxX:Float = pos.x + size.x - rightCap.uv_rect.w - handle.uv_rect.w;
			newPos.x = Maths.clamp(newPos.x, minX, maxX);

			// update the value
			value = (newPos.x - minX) / (maxX - minX);
			for(listener in valueNotifiers) {
				if(listener != null) listener(value);
			}

			// update the geometry
			handle.pos_rect.set(newPos.x, newPos.y);
			_geometry.quad_pos(handle.geometry_id, newPos);
		}
	}

	public function addValueEventListener(_f:Float->Void) {
		valueNotifiers.push(_f);
		_f(value);
	}
}