import luxe.Color;
import luxe.Input;
import luxe.Log;
import luxe.Particles;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import phoenix.BitmapFont;
import phoenix.Texture;
import luxe.Parcel;
import luxe.Text;
import luxe.options.ParticleOptions;
import luxe.resource.Resource;

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

	var loadButton:Button;
	var saveButton:Button;

	var uiFont:BitmapFont;
	var uiFont_2x:BitmapFont;

	override function ready() {
		// load the parcel
		var load = Luxe.resources.load_json('assets/parcel.json');

		load.then(function(json:JSONResource){
			var parcel = new Parcel();
			parcel.from_json(json.asset.json);

			// show a loading bar
			// use a fancy custom loading bar (https://github.com/FuzzyWuzzie/CustomLuxePreloader)
			new DigitalCircleParcelProgress({
				parcel: parcel,
				oncomplete: assetsLoaded,
			});

			// start loading!
			parcel.load();
		});
	} //ready

	function assetsLoaded(_) {

		initParticleSystem();
		initBatchers();
		initUI();
		initSliders();
		initButtons();

	} // assetsLoaded

	function initParticleSystem(){
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
	}

	function reloadParticleSystem(loadedOptions:ParticleEmitterOptions){

		// Clear
		particles.emitters.remove('prototyping');
		emitter.kill();
		emitter = null;

		// No way of changing name so lets keep it constant for a while
		loadedOptions.name = 'prototyping';

		particles.add_emitter(loadedOptions);

		emitter = particles.get('prototyping');
		emitter.init();
	}

	function initBatchers(){

		Luxe.renderer.batcher.add_group(5,
			function(b:phoenix.Batcher) {
				Luxe.renderer.blend_mode(blend_src, blend_dst);
			},
			function(b:phoenix.Batcher) {
				Luxe.renderer.blend_mode();
			}
		);

	}

	function initUI(){

		// Grab the font
		uiFont = Luxe.resources.font('assets/Minecraftia.fnt');
		for(t in uiFont.pages.iterator()) {
			t.filter_min = t.filter_mag = FilterType.nearest;
		}
		ParticlePropertyControl.uiFont = uiFont;

		// Setup the UI texture
		var uiTexture:Texture = Luxe.resources.texture('assets/ui.png');
		uiTexture.filter_min = uiTexture.filter_mag = FilterType.nearest;
		ParticlePropertyControl.uiTexture = uiTexture;


	}

	function initSliders(){

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
		sliders.push(new ParticlePropertyControl("Start Saturation", 0, 1, startColour.s, function(_v:Float) {
			startColour.s = _v;
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
		sliders.push(new ParticlePropertyControl("End Saturation", 0, 1, endColour.s, function(_v:Float) {
			endColour.s = _v;
			emitter.start_color = startColour.toColor();
		}));
		sliders.push(new ParticlePropertyControl("End Alpha", 0, 1, endColour.a, function(_v:Float) {
			endColour.a = _v;
			emitter.end_color = endColour.toColor();
		}));
		sliders.push(new BlendModeControl("SRC", 4, function(_v:Float) { blend_src = Std.int(_v); }));
		sliders.push(new BlendModeControl("DST", 1, function(_v:Float) { blend_dst = Std.int(_v); }));
	}

	function initButtons() {

		// create a button to save
		var tex_btnNormal:Texture = Luxe.resources.texture('assets/btn_normal.png');
		tex_btnNormal.filter_mag = tex_btnNormal.filter_min = FilterType.nearest;
		var tex_btnHover:Texture = Luxe.resources.texture('assets/btn_hover.png');
		tex_btnHover.filter_mag = tex_btnHover.filter_min = FilterType.nearest;
		var tex_btnPressed:Texture = Luxe.resources.texture('assets/btn_pressed.png');
		tex_btnPressed.filter_mag = tex_btnPressed.filter_min = FilterType.nearest;

		loadButton = new Button({
			normalTexture: tex_btnNormal,
			hoverTexture: tex_btnHover,
			pressedTexture: tex_btnPressed,
			onclicked: onLoadClicked,
			top: 8,
			left: 15,
			right: 16,
			bottom: 10,
			pos: new Vector(Luxe.screen.mid.x, Luxe.screen.h - 80),
			text: new Text({
				text: "Load (from JSON)",
				color: new Color(1, 1, 1, 1),
				point_size: 16,
				font: uiFont
			})
		});

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
			text: new Text({
				text: "Save (to JSON)",
				color: new Color(1, 1, 1, 1),
				point_size: 16,
				font: uiFont
			})
		});
	}

	function onLoadClicked() {
		
#if desktop
		// Get the path where to save file
		var path = Luxe.snow.io.module.dialog_open('Open particle file', [{extension:'json', desc:'JSON'}]);

		if(path.length <= 0) return;

		// Save it
		var content = sys.io.File.getContent(path);

		var json = haxe.Json.parse(content);

		// grab loaded particle values
		var loaded:ParticleEmitterOptions = {
			emit_time: json.emit_time,
			emit_count: json.emit_count,
			direction: json.direction,
			direction_random: json.direction_random,
			speed: json.speed,
			speed_random: json.speed_random,
			end_speed: json.end_speed,
			life: json.life,
			life_random: json.life_random,
			rotation: json.zrotation,
			rotation_random: json.rotation_random,
			end_rotation: json.end_rotation,
			end_rotation_random: json.end_rotation_random,
			rotation_offset: json.rotation_offset,
			pos_offset: new Vector(json.pos_offset.x, json.pos_offset.y),
			pos_random: new Vector(json.pos_random.x, json.pos_random.y),
			gravity: new Vector(json.gravity.x, json.gravity.y),
			start_size: new Vector(json.start_size.x, json.start_size.y),
			start_size_random: new Vector(json.start_size_random.x, json.start_size_random.y),
			end_size: new Vector(json.end_size.x, json.end_size.y),
			end_size_random: new Vector(json.end_size_random.x, json.end_size_random.y),
			start_color: new Color(json.start_color.r, json.start_color.g, json.start_color.b, json.start_color.a),
			end_color: new Color(json.end_color.r, json.end_color.g, json.end_color.b, json.end_color.a)
		};
		// TODO: Also grab blend modes
		// blend_src = json.blend_src;
		// blend_dst = json.blend_dst;

		reloadParticleSystem(loaded);

		
#else
		Luxe.snow.window.simple_message("Sorry, this functionality isn't in yet!", "TODO");
#end

	}

	function onSaveClicked() {
		// grab the emitter info and store it in a template
		var template:Dynamic = {
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
			end_color: emitter.end_color,
			blend_src: blend_src,
			blend_dst: blend_dst
		};

		var json = haxe.Json.stringify(template, null, '	');

#if web

		untyped openWindow(json);

#elseif desktop

		// Get the path where to save file
		var path = Luxe.snow.io.module.dialog_save('Save particle file', {extension:'json'});

		if(path.length <= 0) return;

		// Save it
		sys.io.File.saveContent(path, json);

#end
	} // onSaveClicked

} //Main
