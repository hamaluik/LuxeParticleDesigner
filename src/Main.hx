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

import ui.Slider;
import ui.SliderOptions;

class Main extends luxe.Game {
	var sliders:Array<ParticlePropertyControl> = new Array<ParticlePropertyControl>();
	var particles:ParticleSystem;
	var emitter:ParticleEmitter;
	var blend_src:Int;
	var blend_dst:Int;

	var startColour:ColorHSV = new ColorHSV(60, 1, 0.5, 1);
	var endColour:ColorHSV = new ColorHSV(0, 1, 0.5, 0);

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
		particles.add_emitter({
			name: 'prototyping',
			start_size: new Vector(32, 32),
			end_size: new Vector(8, 8),
			gravity: new Vector(0, -90),
			group: 5,
			life: 0.9,
			emit_time: 0.05,
			start_color: startColour.toColor(),
			end_color: endColour.toColor()
		});
		emitter = particles.get('prototyping');
		particles.pos = Luxe.screen.mid;

        Luxe.renderer.batcher.add_group(5,
            function(b:phoenix.Batcher){
                Luxe.renderer.blend_mode(blend_src, blend_dst);
            },
            function(b:phoenix.Batcher){
                Luxe.renderer.blend_mode();
            }
        );

		// setup the UI texture
		var uiTexture:Texture = Luxe.resources.find_texture('assets/ui.png');
		uiTexture.filter = FilterType.nearest;
		ParticlePropertyControl.uiTexture = uiTexture;

		// create a bunch of sliders for the different properties
		sliders.push(new ParticlePropertyControl("Emit Time", 0, 1, 0.05, function(_v:Float) { emitter.emit_time = _v; }));
		sliders.push(new ParticlePropertyControl("Emit Count", 0, 5, 1, function(_v:Float) { emitter.emit_count = Std.int(_v); }));

		sliders.push(new ParticlePropertyControl("Direction", 0, 360, 0, function(_v:Float) { emitter.direction = _v; }));
		sliders.push(new ParticlePropertyControl("Direction Random", 0, 360, 0, function(_v:Float) { emitter.direction_random = _v; }));

		sliders.push(new ParticlePropertyControl("Speed", 0, 10, 0, function(_v:Float) { emitter.speed = _v; }));
		sliders.push(new ParticlePropertyControl("Speed Random", 0, 10, 0, function(_v:Float) { emitter.speed_random = _v; }));
		sliders.push(new ParticlePropertyControl("End Speed", 0, 10, 0, function(_v:Float) { emitter.end_speed = _v; }));

		sliders.push(new ParticlePropertyControl("Life", 0, 5, 0.9, function(_v:Float) { emitter.life = _v; }));
		sliders.push(new ParticlePropertyControl("Life Random", 0, 5, 0, function(_v:Float) { emitter.life_random = _v; }));

		sliders.push(new ParticlePropertyControl("Rotation", 0, 360, 0, function(_v:Float) { emitter.zrotation = _v; }));
		sliders.push(new ParticlePropertyControl("Rotation Random", 0, 360, 0, function(_v:Float) { emitter.rotation_random = _v; }));

		sliders.push(new ParticlePropertyControl("End Rotation", 0, 360, 0, function(_v:Float) { emitter.end_rotation = _v; }));
		sliders.push(new ParticlePropertyControl("End Rotation Random", 0, 360, 0, function(_v:Float) { emitter.end_rotation_random = _v; }));

		sliders.push(new ParticlePropertyControl("Rotation Offset", 0, 360, 0, function(_v:Float) { emitter.rotation_offset = _v; }));

		sliders.push(new ParticlePropertyControl("Pos Offset X", -100, 100, 0, function(_v:Float) { emitter.pos_offset.x = _v; }));
		sliders.push(new ParticlePropertyControl("Pos Offset Y", -100, 100, 0, function(_v:Float) { emitter.pos_offset.y = _v; }));

		sliders.push(new ParticlePropertyControl("Pos Random X", -100, 100, 0, function(_v:Float) { emitter.pos_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("Pos Random Y", -100, 100, 0, function(_v:Float) { emitter.pos_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("Gravity X", -100, 100, 0, function(_v:Float) { emitter.gravity.x = _v; }));
		sliders.push(new ParticlePropertyControl("Gravity Y", -100, 100, -90, function(_v:Float) { emitter.gravity.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Size X", 0, 64, 32, function(_v:Float) { emitter.start_size.x = _v; }));
		sliders.push(new ParticlePropertyControl("Start Size Y", 0, 64, 32, function(_v:Float) { emitter.start_size.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Size Random X", 0, 64, 0, function(_v:Float) { emitter.start_size_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("Start Size Random Y", 0, 64, 0, function(_v:Float) { emitter.start_size_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("End Size X", 0, 64, 8, function(_v:Float) { emitter.end_size.x = _v; }));
		sliders.push(new ParticlePropertyControl("End Size Y", 0, 64, 8, function(_v:Float) { emitter.end_size.y = _v; }));

		sliders.push(new ParticlePropertyControl("End Size Random X", 0, 64, 0, function(_v:Float) { emitter.end_size_random.x = _v; }));
		sliders.push(new ParticlePropertyControl("End Size Random Y", 0, 64, 0, function(_v:Float) { emitter.end_size_random.y = _v; }));

		sliders.push(new ParticlePropertyControl("Start Hue", 0, 360, 60, function(_v:Float) {
			startColour.h = _v;
			emitter.start_color = startColour.toColor();
		}));
		sliders.push(new ParticlePropertyControl("Start Alpha", 0, 1, 1, function(_v:Float) {
			startColour.a = _v;
			emitter.start_color = startColour.toColor();
		}));

		sliders.push(new ParticlePropertyControl("End Hue", 0, 360, 0, function(_v:Float) {
			endColour.h = _v;
			emitter.end_color = endColour.toColor();
		}));
		sliders.push(new ParticlePropertyControl("End Alpha", 0, 1, 0, function(_v:Float) {
			endColour.a = _v;
			emitter.end_color = endColour.toColor();
		}));
		sliders.push(new BlendModeControl("SRC", 4, function(_v:Float) { blend_src = Std.int(_v); }));
		sliders.push(new BlendModeControl("DST", 1, function(_v:Float) { blend_dst = Std.int(_v); }));
	} // assetsLoaded

	override function onkeyup( e:KeyEvent ) {
		if(e.keycode == Key.escape) {
			Luxe.shutdown();
		}

	} //onkeyup

} //Main
