@tool
extends GaeaNodeResource
class_name GaeaNodeRandomScatter
## Randomly places [param amount] [param material]s in the cells of [param reference_data].


func _get_title() -> String:
	return "RandomScatter"


func _get_description() -> String:
	return "Randomly places [param amount] [param material]s in the cells of [param reference_data]."


func _get_arguments_list() -> Array[StringName]:
	return [&"reference_data", &"material", &"amount"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"reference_data": return GaeaValue.Type.DATA
		&"material": return GaeaValue.Type.MATERIAL
		&"amount": return GaeaValue.Type.INT
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference_data", &"material"]


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data: Dictionary = _get_arg(&"reference_data", area, generator_data)
	var material: GaeaMaterial = _get_arg(&"material", area, generator_data)
	var rng := define_rng(generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]
	var cells_to_place_on: Array = grid_data.keys()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(_get_arg(&"amount", area, generator_data), cells_to_place_on.size()))
	
	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		_log_error("Recursive limit reached (%d): Invalid material provided at %s" % [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path], generator_data, generator_data.resources.find(self))
		return grid
	
	for cell: Vector3i in cells_to_place_on:
		grid.set(cell, material.execute_sample(rng, grid_data.get(cell)))

	return grid
