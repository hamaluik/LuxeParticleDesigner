import luxe.Color;
import luxe.Input;
import luxe.Log;
import luxe.Particles;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import phoenix.Texture;
import luxe.Parcel;
import luxe.Text;
import luxe.options.ParticleOptions;

import ui.Slider;
import ui.SliderOptions;
import ui.Button;
import ui.ButtonOptions;

class Main extends luxe.Game {
	var sliders:Array<ParticlePropertyControl> = new Array<ParticlePropertyControl>();
	var particles:ParticleSystem;
	var emitter:ParticleEmitter;
	var blend_src:Int;
	var blend_dst:Int;

	var startColour:ColorHSV = new ColorHSV(60, 1, 0.5, 1);
	var endColour:ColorHSV = new ColorHSV(0, 1, 0.5, 0);

	var saveButton:Button;

	override function ready() {
		// load the parcel
		Luxe.loadJSON("assets/parcel.json", function(jsonParcel) {
			var parcel = new Parcel();
			parcel.from_json(jsonParcel.json);

			// show a loading bar
			// use a fancy custom loading bar (https://github.com/FuzzyWuzzie/CustomLuxePreloader)
			new DigitalCircleParcelProgress({
				parcel: parcel,
				oncomplete: assetsLoaded
			});

			// start loading!
			parcel.load();
		});
	} //ready

	function assetsLoaded(_) {
		// create the particle system
		particles = new ParticleSystem({name: 'particles'});
		var template:ParticleEmitterOptions = {
			name: 'prototyping',
			group: 5,
			emit_time: 0.05,
			emit_count: 1,
			direction: 0,
			direction_random: 0,
			speed: 0,
			speed_random: 0,
			end_speed: 0,
			life: 0.9,
			life_random: 0,
			rotation: 0,
			rotation_random: 0,
			end_rotation: 0,
			end_rotation_random: 0,
			rotation_offset: 0,
			pos_offset: new Vector(0, 0),
			pos_random: new Vector(5, 5),
			gravity: new Vector(0, -90),
			start_size: new Vector(32, 32),
			start_size_random: new Vector(0, 0),
			end_size: new Vector(8, 8),
			end_size_random: new Vector(0, 0),
			start_color: startColour.toColor(),
			end_color: endColour.toColor()
		}
		particles.add_emitter(template);
		emitter = particles.get('prototyping');
		emitter.init();
		particles.pos = Luxe.screen.mid;

        Luxe.renderer.batcher.add_group(5,
            function(b:phoenix.Batcher) {
                Luxe.renderer.blend_mode(blend_src, blend_dst);
            },
            function(b:phoenix.Batcher) {
                Luxe.renderer.blend_mode();
            }
        );

		// setup the UI texture
		var uiTexture:Texture = Luxe.resources.find_texture('assets/ui.png');
		uiTexture.filter = FilterType.nearest;
		ParticlePropertyControl.uiTexture = uiTexture;

		// create a bunch of sliders for the different properties
		sliders.push(new ParticlePropertyControl("Emit Time", 0, 1, emitter.emit_time, function(_v:Float) { emitter.emit_time = _v; }));
		sliders.push(new ParticlePropertyControl("Emit Count", 0, 10, emitter.emit_count, function(_v:Float) { emitter.emit_count = Std.int(_v); }));

		sliders.push(new ParticlePropertyControl("Direction", 0, 360, emitter.direction, function(_v:Float) { emitter.direction = _v; }));
		sliders.push(new ParticlePropertyControl("Direction Random", 0, 360, emitter.direction_random, function(_v:Float) { emitter.direction_random = _v; }));

		sliders.push(new ParticlePropertyControl("Speed", 0, 10, emitter.speed, function(_v:Float) { emitter.speed = _v; }));
		sliders.push(new ParticlePropertyControl("Speed Random", 0, 10, emitter.speed_random, function(_v:Float) { emitter.speed_random = _v; }));
		sliders.push(new ParticlePropertyControl("End Speed", 0, 10, emitter.end_speed, function(_v:Float) { emitter.end_speed = _v; }));

		sliders.push(new ParticlePropertyControl("Life", 0, 5, emitter.life, function(_v:Float) { emitter.life = _v; }));
		sliders.push(new ParticlePropertyControl("Life Random", 0, 5, emitter.life_random, function(_v:Float) { emitter.life_random = _v; }));

		sliders.push(new ParticlePropertyControl("Rotation", 0, 360, emitter.zrotation, function(_v:Float) { emitter.zrotation = _v; }));
		sliders.push(new ParticlePropertyControl("Rotation Random", 0, 360, emitter.rotation_random, function(_v:Float) { emitter.rotation_random = _v; }));

		sliders.push(new ParticlePropertyControl("End Rotation", 0, 360, emitter.end_rotation, function(_v:Float) { emitter.end_rotation = _v; }));
		sliders.push(new ParticlePropertyControl("End Rotation Random", 0, 360, emitter.end_rotation_random, function(_v:Float) { emitter.end_rotation_random = _v; }));

		sliders.push(new ParticlePropertyControl("Rotation Offset", 0, 360, emitter.rotation_offset, function(_v:Float) { emitter.rotation_offset = _v; }));

		sliders.push(new ParticlePropertyControl("Pos Offset X", -100, 100, emitter.pos_offset.x, function(_v:Float) { emitter.pos_offset.x = _v; }));
		sliders.push(new ParticlePropertyControl("Pos Offset Y", -100, 100, emitter.pos_offset.y, function(_v:Float) { emitter.pos_offset.y = _v; }));

		sliders.push(new ParticlePropertyControl("Pos Random X", 0, 100, emitter.pos_random.x, function(_v:Float) { emitter.pos_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("Pos Random Y", 0, 100, emitter.pos_random.y, function(_v:Float) { emitter.pos_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("Gravity X", -100, 100, emitter.gravity.x, function(_v:Float) { emitter.gravity.x = _v; }));
		sliders.push(new ParticlePropertyControl("Gravity Y", -100, 100, emitter.gravity.y, function(_v:Float) { emitter.gravity.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Size X", 0, 64, emitter.start_size.x, function(_v:Float) { emitter.start_size.x = _v; }));
		sliders.push(new ParticlePropertyControl("Start Size Y", 0, 64, emitter.start_size.y, function(_v:Float) { emitter.start_size.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Size Random X", 0, 64, emitter.start_size_random.x, function(_v:Float) { emitter.start_size_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("Start Size Random Y", 0, 64, emitter.start_size_random.y, function(_v:Float) { emitter.start_size_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("End Size X", 0, 64, emitter.end_size.x, function(_v:Float) { emitter.end_size.x = _v; }));
		sliders.push(new ParticlePropertyControl("End Size Y", 0, 64, emitter.end_size.y, function(_v:Float) { emitter.end_size.y = _v; }));

		sliders.push(new ParticlePropertyControl("End Size Random X", 0, 64, emitter.end_size_random.x, function(_v:Float) { emitter.end_size_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("End Size Random Y", 0, 64, emitter.end_size_random.y, function(_v:Float) { emitter.end_size_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Hue", 0, 360, startColour.h, function(_v:Float) {
			startColour.h = _v;
			emitter.start_color = startColour.toColor();
		}));
		sliders.push(new ParticlePropertyControl("Start Alpha", 0, 1, startColour.a, function(_v:Float) {
			startColour.a = _v;
			emitter.start_color = startColour.toColor();
		}));

		sliders.push(new ParticlePropertyControl("End Hue", 0, 360, endColour.h, function(_v:Float) {
			endColour.h = _v;
			emitter.end_color = endColour.toColor();
		}));
		sliders.push(new ParticlePropertyControl("End Alpha", 0, 1, endColour.a, function(_v:Float) {
			endColour.a = _v;
			emitter.end_color = endColour.toColor();
		}));
		sliders.push(new BlendModeControl("SRC", 4, function(_v:Float) { blend_src = Std.int(_v); }));
		sliders.push(new BlendModeControl("DST", 1, function(_v:Float) { blend_dst = Std.int(_v); }));

		// create a button to save
		var tex_btnNormal:Texture = Luxe.resources.find_texture('assets/btn_normal.png');
		tex_btnNormal.filter = FilterType.nearest;
		var tex_btnHover:Texture = Luxe.resources.find_texture('assets/btn_hover.png');
		tex_btnHover.filter = FilterType.nearest;
		var tex_btnPressed:Texture = Luxe.resources.find_texture('assets/btn_pressed.png');
		tex_btnPressed.filter = FilterType.nearest;

		saveButton = new Button({
			normalTexture: tex_btnNormal,
			hoverTexture: tex_btnHover,
			pressedTexture: tex_btnPressed,
			onclicked: onSaveClicked,
			top: 8,
			left: 15,
			right: 16,
			bottom: 10,
			pos: new Vector(Luxe.screen.mid.x, Luxe.screen.h - 32),
			size: new Vector(80, 32),
			text: new Text({
				text: "To JSON!",
				color: new Color(1, 1, 1, 1),
				point_size: 16
			})
		});
	} // assetsLoaded

	function onSaveClicked() {
		// grab the emitter info and store it in a template
		var template:ParticleEmitterOptions = {
			emit_time: emitter.emit_time,
			emit_count: emitter.emit_count,
			direction: emitter.direction,
			direction_random: emitter.direction_random,
			speed: emitter.speed,
			speed_random: emitter.speed_random,
			end_speed: emitter.end_speed,
			life: emitter.life,
			life_random: emitter.life_random,
			rotation: emitter.zrotation,
			rotation_random: emitter.rotation_random,
			end_rotation: emitter.end_rotation,
			end_rotation_random: emitter.end_rotation_random,
			rotation_offset: emitter.rotation_offset,
			pos_offset: emitter.pos_offset,
			pos_random: emitter.pos_random,
			gravity: emitter.gravity,
			start_size: emitter.start_size,
			start_size_random: emitter.start_size_random,
			end_size: emitter.end_size,
			end_size_random: emitter.end_size_random,
			start_color: emitter.start_color,
			end_color: emitter.end_color
		};

		untyped openWindow(haxe.Json.stringify(template));
	} // onSaveClicked

} //Main
