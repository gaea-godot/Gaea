@tool
class_name GaeaNodeTextureSampler
extends GaeaNodeResource
## Samples [param texture] into 4 different sample grids for each channel.


func _get_title() -> String:
	return "TextureSampler"


func _get_description() -> String:
	return "Samples [param texture] into 4 different sample grids for each channel."


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
	return GaeaValue.Type.SAMPLE


func _get_data(output_port: StringName, graph: GaeaGraph, settings: GaeaGenerationSettings) -> GaeaValue.Sample:
	var texture: Texture = _get_arg(&"texture", graph, settings)
	if not is_instance_valid(texture):
		return GaeaValue.get_default_value(GaeaValue.Type.SAMPLE)

	var r_grid: GaeaValue.Sample = GaeaValue.Sample.new()
	var g_grid: GaeaValue.Sample = GaeaValue.Sample.new()
	var b_grid: GaeaValue.Sample = GaeaValue.Sample.new()
	var a_grid: GaeaValue.Sample = GaeaValue.Sample.new()

	var slices: Array[Image]  # Only one is texture is 2D
	if texture is Texture2D:
		slices = [texture.get_image()]
	elif texture is Texture3D:
		slices = texture.get_data()

	if not slices.any(is_instance_valid):
		return GaeaValue.get_default_value(GaeaValue.Type.SAMPLE)

	for x in _get_axis_range(Vector3i.AXIS_X, settings.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, settings.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, settings.area):
				if slices.size() <= z:
					break

				if not is_instance_valid(slices[z]):
					continue

				var cell: Vector3i = Vector3i(x, y, z)
				if not slices[z].get_used_rect().has_point(Vector2i(x, y)):
					continue

				var pixel: Color = slices[z].get_pixel(x, y)
				r_grid.set_cell(cell, pixel.r)
				g_grid.set_cell(cell, pixel.g)
				b_grid.set_cell(cell, pixel.b)
				a_grid.set_cell(cell, pixel.a)

	_set_cached_data(&"r", graph, r_grid)
	_set_cached_data(&"g", graph, g_grid)
	_set_cached_data(&"b", graph, b_grid)
	_set_cached_data(&"a", graph, a_grid)

	return _get_cached_data(output_port, graph)
