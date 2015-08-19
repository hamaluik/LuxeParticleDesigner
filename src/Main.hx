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
	var blend_src:Int;
	var blend_dst:Int;
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
        
        // emission
        controls.set('emissionwindow', new mint.Window({
        	parent: canvas,
        	name: 'emissionwindow',
        	title: 'Emission',
        	x: 10, y: 10, w: 400, h: 158,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
        }));
        makeSlider('emittime', 'Period',  controls.get('emissionwindow'),
                   2, 26, 100, 396, 20,
                   emitter.emit_time, 0, 2, 0.01,
                   function(val:Float, _) {
                   		emitter.emit_time = val;
                   }
        );
        makeSlider('emitcount', 'Count',  controls.get('emissionwindow'),
                   2, 48, 100, 396, 20,
                   emitter.emit_count, 0, 10, 1,
                   function(val:Float, _) {
                   		emitter.emit_count = Std.int(val);
                   }
        );
        makeSlider('emitdirection', 'Direction',  controls.get('emissionwindow'),
                   2, 70, 100, 396, 20,
                   emitter.direction, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.direction = val;
                   }
        );
        makeSlider('emitdirection_random', 'Direction Random',  controls.get('emissionwindow'),
                   2, 92, 100, 396, 20,
                   emitter.direction_random, 0, 360, 1,
                   function(val:Float, _) {
                   		emitter.direction_random = val;
                   }
        );
        makeSlider('emitspeed', 'Speed',  controls.get('emissionwindow'),
                   2, 114, 100, 396, 20,
                   emitter.speed, 0, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.speed = val;
                   }
        );
        makeSlider('emitspeed_random', 'Speed Random',  controls.get('emissionwindow'),
                   2, 136, 100, 396, 20,
                   emitter.speed_random, -10, 10, 0.01,
                   function(val:Float, _) {
                   		emitter.speed_random = val;
                   }
        );
        
        // 
        controls.set('lifewindow', new mint.Window({
        	parent: canvas,
        	name: 'lifewindow',
        	title: 'Life',
        	x: 10, y: 178, w: 400, h: 158,
        	collapsible: true,
        	resizable: true,
        	focusable: true,
        	closable: false,
        	moveable: true
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
