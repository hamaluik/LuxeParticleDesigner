package;

import phoenix.Batcher;

class BlendModeControl extends ParticlePropertyControl{

    var _blend_modes_array:Array<{name:String, value:Int}>;

    public function new(name:String, initial_index:Int, updateParticles:Float->Void) {

        _blend_modes_array = [];
        _blend_modes_array.push({name:"zero", value: BlendMode.zero});
        _blend_modes_array.push({name:"one", value: BlendMode.one});
        _blend_modes_array.push({name:"src_color", value: BlendMode.src_color});
        _blend_modes_array.push({name:"one_minus_src_color", value: BlendMode.one_minus_src_color});
        _blend_modes_array.push({name:"src_alpha", value: BlendMode.src_alpha});
        _blend_modes_array.push({name:"one_minus_src_alpha", value: BlendMode.one_minus_src_alpha});
        _blend_modes_array.push({name:"dst_alpha", value: BlendMode.dst_alpha});
        _blend_modes_array.push({name:"one_minus_dst_alpha", value: BlendMode.one_minus_dst_alpha});
        _blend_modes_array.push({name:"dst_color", value: BlendMode.dst_color});
        _blend_modes_array.push({name:"one_minus_dst_color", value: BlendMode.one_minus_dst_color});
        _blend_modes_array.push({name:"src_alpha_saturate", value: BlendMode.src_alpha_saturate});

        super(name, 0, _blend_modes_array.length - 1, initial_index, updateParticles);
		valueDisplay.text = name;
    }

    override function valueChanged(_v:Float) {
        _v = _v * (max - min) + min;
        var val = _blend_modes_array[Std.int(_v)];
        title.text = val.name;
		try {
			updateParticles(val.value);
		}
		catch(e:Dynamic) {}
	}
}
