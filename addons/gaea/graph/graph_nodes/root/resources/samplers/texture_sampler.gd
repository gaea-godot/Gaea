@tool
class_name GaeaNodeTextureSampler
extends GaeaNodeResource
## Samples [param texture] into 4 different data grids for each channel.


func _get_title() -> String:
	return "TextureSampler"


func _get_description() -> String:
	return "Samples [param texture] into 4 different data grids for each channel."


# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	return [&"texture"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.TEXTURE


# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return [&"r", &"g", &"b", &"a"]


func _get_output_port_display_name(output_name: StringName) -> String:
	return output_name


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var texture: Texture = _get_arg(&"texture", area, graph)
	if not is_instance_valid(texture):
		return {}

	var r_grid: Dictionary[Vector3i, float]
	var g_grid: Dictionary[Vector3i, float]
	var b_grid: Dictionary[Vector3i, float]
	var alpha_grid: Dictionary[Vector3i, float]

	var slices: Array[Image] # Only one is texture is 2D
	if texture is Texture2D:
		slices = [texture.get_image()]
	elif texture is Texture3D:
		slices = texture.get_data()

	if not slices.any(is_instance_valid):
		return {}

	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			for z in _get_axis_range(Vector3i.AXIS_Z, area):
				if slices.size() <= z:
					break

				if not is_instance_valid(slices[z]):
					continue

				var cell: Vector3i = Vector3i(x, y, z)
				if not slices[z].get_used_rect().has_point(Vector2i(x, y)):
					continue

				var pixel: Color = slices[z].get_pixel(x, y)
				r_grid.set(cell, pixel.r)
				g_grid.set(cell, pixel.g)
				b_grid.set(cell, pixel.b)
				alpha_grid.set(cell, pixel.a)

	_set_cached_data(&"r", graph, r_grid)
	_set_cached_data(&"g", graph, g_grid)
	_set_cached_data(&"b", graph, b_grid)
	_set_cached_data(&"a", graph, alpha_grid)

	return _get_cached_data(output_port, graph)
