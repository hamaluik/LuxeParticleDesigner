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

import mint.Canvas;
import mint.render.luxe.LuxeMintRender;
import mint.render.Rendering;
import mint.types.Types;
import mint.Control;
import mint.render.luxe.Convert;

import mint.layout.margins.Margins;

class Main extends luxe.Game {
	// particle options
	var particles:ParticleSystem;
	var emitter:ParticleEmitter;
	var blendSrc:Int;
	var blendDst:Int;
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

	override function ready() {
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
			start_color: startColour.toColor(),
			end_color: endColour.toColor()
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
				Luxe.renderer.blend_mode(blendSrc, blendDst);
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
						emitter.start_color = startColour.toColor();
                   }
        );
        makeSlider('startsaturation', 'Start Saturation',  controls.get('colourwindow'),
                   2, 48, 120, 396, 20,
                   startColour.s, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.s = val;
						emitter.start_color = startColour.toColor();
                   }
        );
        makeSlider('startvalue', 'Start Value',  controls.get('colourwindow'),
                   2, 70, 120, 396, 20,
                   startColour.v, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.v = val;
						emitter.start_color = startColour.toColor();
                   }
        );
        makeSlider('startalpha', 'Start Alpha',  controls.get('colourwindow'),
                   2, 92, 120, 396, 20,
                   startColour.a, 0, 1, 0.01,
                   function(val:Float, _) {
                   		startColour.a = val;
						emitter.start_color = startColour.toColor();
                   }
        );
        makeSlider('endhue', 'End Hue',  controls.get('colourwindow'),
                   2, 114, 120, 396, 20,
                   endColour.h, 0, 360, 1,
                   function(val:Float, _) {
                   		endColour.h = val;
						emitter.end_color = endColour.toColor();
                   }
        );
        makeSlider('endsaturation', 'End Saturation',  controls.get('colourwindow'),
                   2, 136, 120, 396, 20,
                   endColour.s, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.s = val;
						emitter.end_color = endColour.toColor();
                   }
        );
        makeSlider('endvalue', 'End Value',  controls.get('colourwindow'),
                   2, 158, 120, 396, 20,
                   endColour.v, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.v = val;
						emitter.end_color = endColour.toColor();
                   }
        );
        makeSlider('endalpha', 'End Alpha',  controls.get('colourwindow'),
                   2, 180, 120, 396, 20,
                   endColour.a, 0, 1, 0.01,
                   function(val:Float, _) {
                   		endColour.a = val;
						emitter.end_color = endColour.toColor();
                   }
        );
        makeDropdown('blendsrc', 'SRC Blending',  controls.get('colourwindow'),
                   2, 202, 396, 20,
                   blendModes,
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 blendSrc = idx;
                   }, true
        );
        makeDropdown('blenddst', 'DST Blending',  controls.get('colourwindow'),
                   2, 224, 396, 20,
                   blendModes,
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 blendDst = idx;
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
        	x: Luxe.screen.width - 410, y: 498, w: 400, h: 400,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
		controls.set('examples_label', new mint.Label({
			name: 'examples_label',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 2, y: 26, w: 50, h: 20,
			text: 'Example:',
			align: TextAlign.right, align_vertical: TextAlign.center
		}));
        makeDropdown('example_dropdown', '',  controls.get('saveloadwindow'),
                   54, 26, 200, 20,
                   ['fireflies'],
                   function(idx:Int, c:Control, e:MouseEvent) {
                   		 trace("Not implemented yet!");
                   }, false
        );
		controls.set('examples_loadbtn', new mint.Button({
			name: 'examples_loadbtn',
			parent: controls.get('saveloadwindow'),
			text_size: 12,
			x: 256, y: 26, w: 142, h: 20,
			text: 'Load!',
			onclick: function(_, _) {
				trace('Not implemented yet!');
			}
		}));
	}
	
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
	}
	
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
	}

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
