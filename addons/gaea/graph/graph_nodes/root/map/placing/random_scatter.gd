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
	return GaeaValue.Type.NULL


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference_data", &"material"]


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, GaeaMaterial]:
	var grid_data: Dictionary = _get_arg(&"reference_data", area, graph)
	var material: GaeaMaterial = _get_arg(&"material", area, graph)
	var rng := define_rng(graph)

	var grid: Dictionary[Vector3i, GaeaMaterial]
	var cells_to_place_on: Array = grid_data.keys()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(_get_arg(&"amount", area, graph), cells_to_place_on.size()))

	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		material = _get_arg(&"material", area, graph)
		_log_error(
			"Recursive limit reached (%d): Invalid material provided at %s" % [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path],
			graph,
			id
		)
		return grid

	for cell: Vector3i in cells_to_place_on:
		grid.set(cell, material.execute_sample(rng, grid_data.get(cell)))

	return grid
