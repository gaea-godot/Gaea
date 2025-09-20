@tool
@abstract
extends GaeaNodeResource
class_name GaeaNodeNoise
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
} # This has to be copied because you can't use FastNoiseLite.NoiseType directly.


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
		&"frequency": return 0.01
		&"lacunarity": return 2.0
		&"octaves": return 5
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var _noise: FastNoiseLite = FastNoiseLite.new()
	_noise.seed = graph.generator.seed + salt
	_noise.noise_type = get_enum_selection(0) as FastNoiseLite.NoiseType

	_noise.frequency = _get_arg(&"frequency", area, graph)
	_noise.fractal_octaves = _get_arg(&"octaves", area, graph)
	_noise.fractal_lacunarity = _get_arg(&"lacunarity", area, graph)
	var dictionary: Dictionary[Vector3i, float]
	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			for z in _get_axis_range(Vector3i.AXIS_Z, area):
				dictionary[Vector3i(x, y, z)] = (_get_noise_value(Vector3i(x, y, z), _noise) + 1.0) / 2.0
	return dictionary



func _get_noise_value(_cell: Vector3i, _noise: FastNoiseLite) -> float:
	return -1.0
