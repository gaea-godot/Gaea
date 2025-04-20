@tool
extends GaeaNodeResource
class_name GaeaNodeSimplexSmooth
## Creates a grid of values from [code]0.0[/code] to [code]1.0[/code] based on a SimplexSmooth noise texture.
##
## Generic class for both the 2D and 3D version of this node.


## Whether it uses the [method Noise.get_noise_2d] or [method Noise.get_noise_3d].
@export_enum("2D", "3D") var type = 0


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var _noise: FastNoiseLite = FastNoiseLite.new()
	_noise.seed = generator_data.generator.seed + salt

	_noise.frequency = _get_arg(&"frequency", area, generator_data)
	_noise.fractal_octaves = _get_arg(&"octaves", area, generator_data)
	_noise.fractal_lacunarity = _get_arg(&"lacunarity", area, generator_data)
	var dictionary: Dictionary[Vector3i, float]
	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			for z in _get_axis_range(Axis.Z, area):
				dictionary[Vector3i(x, y, z)] = (_get_noise_value(Vector3i(x, y, z), _noise) + 1.0) / 2.0
	return output_port.return_value(dictionary)


func _get_noise_value(cell: Vector3i, noise: FastNoiseLite) -> float:
	if type == 0:
		return noise.get_noise_2d(cell.x, cell.y)
	else:
		return noise.get_noise_3d(cell.x, cell.y, cell.z)
