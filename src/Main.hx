import haxe.ds.StringMap;
import luxe.Color;
import luxe.Input;
import luxe.Log;
import luxe.Particles;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.Text;
import luxe.options.ParticleOptions;
import luxe.resource.Resource;
import luxe.Parcel;
import luxe.ParcelProgress;

import mint.Canvas;
import mint.render.luxe.LuxeMintRender;
import mint.render.Rendering;
import mint.types.Types;
import mint.Control;
import mint.render.luxe.Convert;

import mint.layout.margins.Margins;

class Main extends luxe.Game {
	static var instance:Main;
	
	// particle options
	var particles:ParticleSystem;
	var emitter:ParticleEmitter;
	var blend_src:Int;
	var blend_dst:Int;
	var blendModes:Array<String> = ['zero', 'one', 'src_color', 'one_minus_src_color',
									'src_alpha', 'one_minus_src_alpha', 'dst_alpha',
									'one_minus_dst_alpha', 'dst_color', 'one_minus_dst_color',
									'src_alpha_saturate'];
	var startColour:ColorHSV = new ColorHSV(60, 1, 0.5, 1);
	var endColour:ColorHSV = new ColorHSV(0, 1, 0.5, 0);
	
	// UI stuff
    var rendering:LuxeMintRender;
    var layout:Margins;
    var canvas:Canvas;
    var controls:StringMap<Control>;
    
    // examples
	var examples:Array<String> = ['blockyflame', 'fireflies'];
	var exampleIDX:Int = -1;

	override function ready() {
		instance = this;
		initParticleSystem();
		initBatchers();
		initUI();
	} //ready

	function initParticleSystem() {
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
			start_color: startColour,
			end_color: endColour
		}
		particles.add_emitter(template);
		emitter = particles.get('prototyping');
		emitter.init();
		particles.pos = Luxe.screen.mid;
	}

	function reloadParticleSystem(loadedOptions:ParticleEmitterOptions) {
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

	function initBatchers() {
		Luxe.renderer.batcher.add_group(5,
			function(b:phoenix.Batcher) {
				Luxe.renderer.blend_mode(blend_src, blend_dst);
			},
			function(b:phoenix.Batcher) {
				Luxe.renderer.blend_mode();
			}
		);
	}

	function initUI() {
        // set up mint
        rendering = new LuxeMintRender();
        layout = new Margins();
        
        // create a canvas
        canvas = new Canvas({
            x: 0, y: 0, w: Luxe.screen.width, h: Luxe.screen.height,
            rendering: rendering,
            options: { color:new Color(1, 1, 1, 0.0) },
        });

        // create some controls
        controls = new StringMap<Control>();

        
        controls.set('emissionwindow', new mint.Window({
        	parent: canvas,
        	name: 'emissionwindow',
        	title: 'Emission',
        	x: 10, y: 10, w: 400, h: 202,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('emittime', 'Period',  controls.get('emissionwindow'),
                   2, 26, 120, 396, 20,
                   emitter.emit_time, 0, 2, 0.01,
                   function(val:Float, _) {
                   		emitter.emit_time = val;
                   }
        );
        makeSlider('emitcount', 'Count',  controls.get('emissionwindow'),
                   2, 48, 120, 396, 20,
                   emitter.emit_count, 0, 10, 1,
                   function(val:Float, _) {
                   		emitter.emit_count = Std.int(val);
                   }
        );
        makeSlider('emitdirection', 'Direction',  controls.get('emissionwindow'),
                   2, 70, 120, 396, 20,
                   emitter.direction, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.direction = val;
                   }
        );
        makeSlider('emitdirection_random', 'Direction Random',  controls.get('emissionwindow'),
                   2, 92, 120, 396, 20,
                   emitter.direction_random, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.direction_random = val;
                   }
        );
        makeSlider('emitspeed', 'Speed',  controls.get('emissionwindow'),
                   2, 114, 120, 396, 20,
                   emitter.speed, 0, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.speed = val;
                   }
        );
        makeSlider('emitspeed_random', 'Speed Random',  controls.get('emissionwindow'),
                   2, 136, 120, 396, 20,
                   emitter.speed_random, -10, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.speed_random = val;
                   }
        );
        makeSlider('life', 'Life',  controls.get('emissionwindow'),
                   2, 158, 120, 396, 20,
                   emitter.life, 0, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.life = val;
                   }
        );
        makeSlider('life_random', 'Life Random',  controls.get('emissionwindow'),
                   2, 180, 120, 396, 20,
                   emitter.life_random, -10, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.life_random = val;
                   }
        );
        

        controls.set('sizewindow', new mint.Window({
        	parent: canvas,
        	name: 'sizewindow',
        	title: 'Size',
        	x: 10, y: 222, w: 400, h: 202,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('startsizex', 'Start Size (x)',  controls.get('sizewindow'),
                   2, 26, 120, 396, 20,
                   emitter.start_size.x, 0, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.start_size.x = val;
                   }
        );
        makeSlider('startsizey', 'Start Size (y)',  controls.get('sizewindow'),
                   2, 48, 120, 396, 20,
                   emitter.start_size.y, 0, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.start_size.y = Std.int(val);
                   }
        );
        makeSlider('startsizex_random', 'Start Size (x) Random',  controls.get('sizewindow'),
                   2, 70, 120, 396, 20,
                   emitter.start_size_random.x, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.start_size_random.x = val;
                   }
        );
        makeSlider('startsizey_random', 'Start Size (y) Random',  controls.get('sizewindow'),
                   2, 92, 120, 396, 20,
                   emitter.start_size_random.y, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.start_size_random.y = val;
                   }
        );
        makeSlider('endsizex', 'End Size (x)',  controls.get('sizewindow'),
                   2, 114, 120, 396, 20,
                   emitter.end_size.x, 0, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.end_size.x = val;
                   }
        );
        makeSlider('endsizey', 'End Size (y)',  controls.get('sizewindow'),
                   2, 136, 120, 396, 20,
                   emitter.end_size.y, 0, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.end_size.y = Std.int(val);
                   }
        );
        makeSlider('endsizex_random', 'End Size (x) Random',  controls.get('sizewindow'),
                   2, 158, 120, 396, 20,
                   emitter.end_size_random.x, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.end_size_random.x = val;
                   }
        );
        makeSlider('endsizey_random', 'End Size (y) Random',  controls.get('sizewindow'),
                   2, 180, 120, 396, 20,
                   emitter.end_size_random.y, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.end_size_random.y = val;
                   }
        );
        
        
        controls.set('gravitywindow', new mint.Window({
        	parent: canvas,
        	name: 'gravitywindow',
        	title: 'Gravity',
        	x: 10, y: 434, w: 400, h: 70,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('gravityx', 'Gravity (x)',  controls.get('gravitywindow'),
                   2, 26, 120, 396, 20,
                   emitter.gravity.x, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.gravity.x = val;
                   }
        );
        makeSlider('gravityy', 'Gravity (y)',  controls.get('gravitywindow'),
                   2, 48, 120, 396, 20,
                   emitter.gravity.y, -128, 128, 0.1,
                   function(val:Float, _) {
                   		emitter.gravity.y = Std.int(val);
                   }
        );
        
        
        controls.set('colourwindow', new mint.Window({
        	parent: canvas,
        	name: 'colourwindow',
        	title: 'Colour',
        	x: Luxe.screen.width - 410, y: 10, w: 400, h: 246,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('starthue', 'Start Hue',  controls.get('colourwindow'),
                   2, 26, 120, 396, 20,
                   startColour.h, 0, 360, 1,
                   function(val:Float, _) {
                   		startColour.h = val;
						emitter.start_color = startColour;
                   }
        );
        makeSlider('startsaturation', 'Start Saturation',  controls.get('colourwindow'),
                   2, 48, 120, 396, 20,
                   startColour.s, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.s = val;
						emitter.start_color = startColour;
                   }
        );
        makeSlider('startvalue', 'Start Value',  controls.get('colourwindow'),
                   2, 70, 120, 396, 20,
                   startColour.v, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.v = val;
						emitter.start_color = startColour;
                   }
        );
        makeSlider('startalpha', 'Start Alpha',  controls.get('colourwindow'),
                   2, 92, 120, 396, 20,
                   startColour.a, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.a = val;
						emitter.start_color = startColour;
                   }
        );
        makeSlider('endhue', 'End Hue',  controls.get('colourwindow'),
                   2, 114, 120, 396, 20,
                   endColour.h, 0, 360, 1,
                   function(val:Float, _) {
                   		endColour.h = val;
						emitter.end_color = endColour;
                   }
        );
        makeSlider('endsaturation', 'End Saturation',  controls.get('colourwindow'),
                   2, 136, 120, 396, 20,
                   endColour.s, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.s = val;
						emitter.end_color = endColour;
                   }
        );
        makeSlider('endvalue', 'End Value',  controls.get('colourwindow'),
                   2, 158, 120, 396, 20,
                   endColour.v, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.v = val;
						emitter.end_color = endColour;
                   }
        );
        makeSlider('endalpha', 'End Alpha',  controls.get('colourwindow'),
                   2, 180, 120, 396, 20,
                   endColour.a, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.a = val;
						emitter.end_color = endColour;
                   }
        );
        makeDropdown('blend_src', 'SRC Blending',  controls.get('colourwindow'),
                   2, 202, 396, 20,
                   blendModes,
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 blend_src = idx;
                   }, true
        );
        makeDropdown('blend_dst', 'DST Blending',  controls.get('colourwindow'),
                   2, 224, 396, 20,
                   blendModes,
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 blend_dst = idx;
                   }, true
        );
        
        
        controls.set('transformwindow', new mint.Window({
        	parent: canvas,
        	name: 'transformwindow',
        	title: 'Transform',
        	x: Luxe.screen.width - 410, y: 266, w: 400, h: 222,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('startrotation', 'Start Rotation',  controls.get('transformwindow'),
                   2, 26, 120, 396, 20,
                   emitter.zrotation, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.zrotation = val;
                   }
        );
        makeSlider('startrotation_random', 'Start Rotation Random',  controls.get('transformwindow'),
                   2, 48, 120, 396, 20,
                   emitter.rotation_random, -360, 360, 1,
                   function(val:Float, _) {
                   		emitter.rotation_random = val;
                   }
        );
        makeSlider('endrotation', 'End Rotation',  controls.get('transformwindow'),
                   2, 70, 120, 396, 20,
                   emitter.end_rotation, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.end_rotation = val;
                   }
        );
        makeSlider('endrotation_random', 'End Rotation Random',  controls.get('transformwindow'),
                   2, 92, 120, 396, 20,
                   emitter.end_rotation_random, -360, 360, 1,
                   function(val:Float, _) {
                   		emitter.end_rotation_random = val;
                   }
        );
        makeSlider('rotationoffset', 'Rotation Offset',  controls.get('transformwindow'),
                   2, 114, 120, 396, 20,
                   emitter.rotation_offset, -360, 360, 1,
                   function(val:Float, _) {
                   		emitter.rotation_offset = val;
                   }
        );
        makeSlider('posoffsetx', 'Position Offset (x)',  controls.get('transformwindow'),
                   2, 136, 120, 396, 20,
                   emitter.pos_offset.x, -128, 128, 1,
                   function(val:Float, _) {
                   		emitter.pos_offset.x = val;
                   }
        );
        makeSlider('posoffsety', 'Position Offset (y)',  controls.get('transformwindow'),
                   2, 158, 120, 396, 20,
                   emitter.pos_offset.y, -128, 128, 1,
                   function(val:Float, _) {
                   		emitter.pos_offset.y = val;
                   }
        );
        makeSlider('pos_randomx', 'Position Random (x)',  controls.get('transformwindow'),
                   2, 180, 120, 396, 20,
                   emitter.pos_random.x, -128, 128, 1,
                   function(val:Float, _) {
                   		emitter.pos_random.x = val;
                   }
        );
        makeSlider('pos_randomy', 'Position Random (y)',  controls.get('transformwindow'),
                   2, 202, 120, 396, 20,
                   emitter.pos_random.y, -128, 128, 1,
                   function(val:Float, _) {
                   		emitter.pos_random.y = val;
                   }
        );
        
        
        controls.set('saveloadwindow', new mint.Window({
        	parent: canvas,
        	name: 'saveloadwindow',
        	title: 'Save / Load',
        	x: Luxe.screen.width - 410, y: 498, w: 400, h: 114,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
		controls.set('particlesname_label', new mint.Label({
			name: 'particlesname_label',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 2, y: 26, w: 100, h: 20,
			text: 'Particles Name:',
			align: TextAlign.left, align_vertical: TextAlign.center
		}));
		controls.set('examples_loadjsonbtn', new mint.Button({
			name: 'examples_loadjsonbtn',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 2, y: 48, w: 396, h: 20,
			text: 'Load (from JSON)',
			onclick: function(_, _) {
				#if web
					untyped openLoadWindow();
				#elseif desktop
					// Get the path where to save file
					var path = Luxe.snow.io.module.dialog_open('Open particle file', [{extension:'json', desc:'JSON'}]);
					if(path.length <= 0) return;
					// Save it
					var content:String = sys.io.File.getContent(path);
					
					loadFromJSONText(content);
				#end
			}
		}));
		controls.set('examples_savejsonbtn', new mint.Button({
			name: 'examples_savejsonbtn',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 2, y: 70, w: 396, h: 20,
			text: 'Save (to JSON)',
			onclick: function(_, _) {
				saveToJSON();
			}
		}));
		controls.set('examples_label', new mint.Label({
			name: 'examples_label',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 2, y: 92, w: 50, h: 20,
			text: 'Example:',
			align: TextAlign.right, align_vertical: TextAlign.center
		}));
        makeDropdown('example_dropdown', '',  controls.get('saveloadwindow'),
                   54, 92, 200, 20,
                   examples,
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 exampleIDX = idx;
                   		 cast(controls.get('examples_loadbtn'), mint.Button).mouse_input = true;
                   }, false
        );
		controls.set('examples_loadbtn', new mint.Button({
			name: 'examples_loadbtn',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 256, y: 92, w: 142, h: 20,
			text: 'Load!',
			mouse_input: false,
			onclick: function(_, _) {
				var parcel:Parcel = new Parcel({
					jsons: [{ id: 'assets/particles_${examples[exampleIDX]}.json' }]
				});
				new ParcelProgress({
					parcel: parcel,
					background: new Color(0, 0, 0, 0),
					oncomplete: function(_) {
						loadFromJSON(Luxe.resources.json('assets/particles_${examples[exampleIDX]}.json').asset.json);
					}
				});
				parcel.load();
			}
		}));
	} // initUI
	
	inline function makeSlider(name:String, label:String, parent:Control,
	                           x:Float, y:Float, labelW:Float, w:Float, h:Float,
	                           value:Float, min:Float, max:Float, step:Float,
	                           ?onchange:Float->Float->Void) {
		// make a string label describing what this is
		var label:mint.Label = new mint.Label({
			name: name + '_label',
			parent: parent,
			text_size: 12,
			x: x, y: y, w: labelW, h: h,
			text: label + ':',
			align: TextAlign.right, align_vertical: TextAlign.center
		});
		controls.set(name + '_label', label);
		
		// create the actual slider
		var slider:mint.Slider = new mint.Slider({
			name: name,
			parent: parent,
			x: x + labelW + 2, y: y, w: w - labelW - 2, h: h,
			value: value, min: min, max: max, step: step,
			vertical: false
		});
		controls.set(name, slider);
		
		// create an indicator to show the actual value
		var indicator:mint.Label = new mint.Label({
			name: name + '_indicator',
			parent: slider,
			text_size: 12,
			x: 0, y: 0, w: w - labelW - 2, h: h,
			text: '${slider.value}',
			align: TextAlign.center, align_vertical: TextAlign.center
		});
		controls.set(name + '_indicator', slider);
		
		// update the indicator!
		slider.onchange.listen(function(val:Float, _) {
			indicator.text = '$val';
		});
		
		// add the custom onchange callback
		slider.onchange.listen(onchange);
	} // makeSlider
	
	inline function makeDropdown(name:String, label:String, parent:Control,
	                             x:Float, y:Float, w:Float, h:Float,
	                             items:Array<String>,
	                             onchange:Int->Control->MouseEvent->Void,
	                             prependLabel:Bool) {
		var dropdown:mint.Dropdown = new mint.Dropdown({
			parent: parent,
			name: name, text: label,
			x: x, y: y, w: w, h: h
		});
		controls.set(name, dropdown);

		var first:Bool = true;
		for(item in items) {
            dropdown.add_item(
                new mint.Label({
                    parent: dropdown, text: '$item', align:TextAlign.left,
                    name: '$name-$item', w: w - 20, h: h, text_size: 14
                }),
                10, (first) ? 0 : 10
            );
            if(first) {
            	first = false;
            }
		}

		dropdown.onselect.listen(function(idx:Int,_,_) { dropdown.label.text = (prependLabel ? (label + ": ") : '') + items[idx]; });
		dropdown.onselect.listen(onchange);
	} // makeDropdown

	#if web	
		@:expose("loadFromJSONTextWindow")
		static function loadFromJSONTextWindow(text:String) {
			instance.loadFromJSONText(text);
		}
	#end
	
	function loadFromJSONText(text:String) {
		// parse the JSON
		var json:Dynamic = haxe.Json.parse(text);
		loadFromJSON(json);
	}
	
	function loadFromJSON(json:Dynamic) {
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
		blend_src = json.blend_src;
		blend_dst = json.blend_dst;

		reloadParticleSystem(loaded);
	} // loadFromJSON
	
	function saveToJSON() {
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
			//untyped openWindow(json);
			untyped saveJSON(json);
		#elseif desktop
			// Get the path where to save file
			var path = Luxe.snow.io.module.dialog_save('Save particle file', {extension:'json'});
			if(path.length <= 0) return;
			// Save it
			sys.io.File.saveContent(path, json);
		#end
	} // saveToJSON

    override function onmousemove(e) {
        if(canvas != null) canvas.mousemove(Convert.mouse_event(e));
    } // onmousemove

    override function onmousewheel(e) {
       if(canvas != null) canvas.mousewheel(Convert.mouse_event(e));
    } // onmousewheel

    override function onmouseup(e) {
       if(canvas != null) canvas.mouseup(Convert.mouse_event(e));
    } // onmouseup

    override function onmousedown(e) {
       if(canvas != null) canvas.mousedown(Convert.mouse_event(e));
    } // onmousedown

    override function onkeydown(e:luxe.Input.KeyEvent) {
       if(canvas != null) canvas.keydown(Convert.key_event(e));
    } // onkeydown

    override function ontextinput(e:luxe.Input.TextEvent) {
       if(canvas != null) canvas.textinput(Convert.text_event(e));
    } // ontextinput

    override function onkeyup(e:luxe.Input.KeyEvent) {
       if(canvas != null) canvas.keyup(Convert.key_event(e));
    } // onkeyup

    override function onrender() {
       if(canvas != null) canvas.render();
    } // onrender

    override function update(dt:Float) {
       if(canvas != null) canvas.update(dt);
    } // update

} //Main
