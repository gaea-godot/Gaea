@tool
extends GaeaNodeResource
class_name GaeaNodeGradientMapper
## Takes a [GaeaMaterialGradient] resource and samples the
## corresponding material to the values in [param data].


func _get_title() -> String:
	return "GradientMapper"


func _get_description() -> String:
	return "Takes a GaeaMaterialGradient resource and samples the corresponding material to the values in [param]reference_data[/bg][/c]."


func _get_arguments_list() -> Array[StringName]:
	return [&"data", &"gradient"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"data": return GaeaValue.Type.DATA
		&"gradient": return GaeaValue.Type.GRADIENT
	return super(arg_name)


func _get_required_arguments() -> Array[StringName]:
	return [&"data", &"gradient"]


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data: Dictionary = _get_arg(&"data", area, generator_data)
	var gradient: GaeaMaterialGradient = _get_arg(&"gradient", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	if not is_instance_valid(gradient):
		return grid

	for cell in grid_data:
		if grid_data.get(cell) == null:
			continue

		var material: GaeaMaterial = gradient.sample(grid_data.get(cell))
		if is_instance_valid(material):
			grid[cell] = material.get_resource()

	return grid
