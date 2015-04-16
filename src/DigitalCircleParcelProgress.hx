package ;

import luxe.resource.Resource;
import luxe.Parcel;
import luxe.Visual;
import luxe.Color;
import luxe.options.ParcelProgressOptions;
import luxe.Text;
import luxe.Vector;

class DigitalCircleParcelProgress {
	var parcel:Parcel;

	var ticks:Array<Visual> = new Array<Visual>();
	var progressText:Text;

	var options:ParcelProgressOptions;

	public function new(_options:ParcelProgressOptions) {
		options = _options;

		if(options.bar == null) {
			options.bar = new Color( ).rgb(0xC7F464);
		}

		if(options.background == null) {
			options.background = new Color( ).rgb(0x556270);
		}

		// create the ticks
		for(i in 0...20) {
			var angle:Float = (i * (Math.PI / 10)) - (Math.PI / 2);
			var start:Vector = new Vector(30 * Math.cos(angle) + Luxe.screen.mid.x, 30 * Math.sin(angle) + Luxe.screen.mid.y);
			var end:Vector = new Vector(40 * Math.cos(angle) + Luxe.screen.mid.x, 40 * Math.sin(angle) + Luxe.screen.mid.y);

			ticks.push(new Visual({
				color: options.background,
				no_scene: true,
				geometry : Luxe.draw.line({
					p0: start,
					p1: end
				}),
				depth: 998
			}));
		}

		// create the percent text
		progressText = new luxe.Text({
    		text: '0%',
    		align: center,
    		align_vertical: center,
    		point_size: 12,
    		pos: Luxe.screen.mid,
    		color: new Color().rgb(0xFF6B6B)
    	});

		// intercept the oncomplete and onprogress callbacks
		options.parcel.options.oncomplete = oncomplete;
		options.parcel.options.onprogress = onprogress;
	}

	public function onprogress(r:Resource) {
		var amount = options.parcel.current_count / options.parcel.total_items;
		for(i in 0...20) {
			if(amount >= (i / 20)) {
				ticks[i].color = options.bar;
			}
		}

		progressText.text = Std.int(amount * 100) + "%";
	}

	public function oncomplete(p:Parcel) {
		for(tick in ticks) {
			tick.destroy();
		}
		progressText.destroy();

		if(options.oncomplete != null) {
			options.oncomplete(options.parcel);
		}
	}
}