@tool
@abstract
class_name GaeaNodeNoise
extends GaeaNodeResource
## Creates a grid of values from [code]0.0[/code] to [code]1.0[/code] based on a noise algorithm.
##
## Base class for both the 2D and 3D version of this node.

enum NoiseType {
	SIMPLEX = FastNoiseLite.NoiseType.TYPE_SIMPLEX,
	SIMPLEX_SMOOTH = FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH,
	CELLULAR = FastNoiseLite.NoiseType.TYPE_CELLULAR,
	PERLIN = FastNoiseLite.NoiseType.TYPE_PERLIN,
	VALUE_CUBIC = FastNoiseLite.NoiseType.TYPE_VALUE_CUBIC,
	VALUE = FastNoiseLite.NoiseType.TYPE_VALUE
}  # This has to be copied because you can't use FastNoiseLite.NoiseType directly.


func _get_title() -> String:
	return "Noise"


func _get_description() -> String:
	return "Creates a grid of values from [code]0[/code] to [code]1[/code] based on a noise algorithm."


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	return NoiseType


func _get_enum_default_value(_enum_idx: int) -> int:
	return NoiseType.SIMPLEX_SMOOTH


func _get_arguments_list() -> Array[StringName]:
	return [&"frequency", &"lacunarity", &"octaves"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT if arg_name == &"octaves" else GaeaValue.Type.FLOAT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"frequency":
			return 0.01
		&"lacunarity":
			return 2.0
		&"octaves":
			return 5
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"noise"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = pouch.settings.seed + salt
	noise.noise_type = get_enum_selection(0) as FastNoiseLite.NoiseType

	noise.frequency = _get_arg(&"frequency", graph, pouch)
	noise.fractal_octaves = _get_arg(&"octaves", graph, pouch)
	noise.fractal_lacunarity = _get_arg(&"lacunarity", graph, pouch)
	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				var noise_value := _get_noise_value(Vector3i(x, y, z), noise)
				result.set_xyz(x, y, z, (noise_value + 1.0) * 0.5)
	return result


func _get_noise_value(_cell: Vector3i, _noise: FastNoiseLite) -> float:
	return -1.0
