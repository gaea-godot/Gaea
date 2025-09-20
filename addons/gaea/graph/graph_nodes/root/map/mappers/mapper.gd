@tool
@abstract
class_name GaeaNodeMapper
extends GaeaNodeResource
## Abstract class for mappers.


func _get_arguments_list() -> Array[StringName]:
	return [&"reference_data", &"material"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA if arg_name == &"reference_data" else GaeaValue.Type.MATERIAL


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference_data", &"material"]


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, GaeaMaterial]:
	var grid: Dictionary[Vector3i, GaeaMaterial] = {}
	var grid_data := _get_arg(&"reference_data", area, graph) as Dictionary
	var material := _get_arg(&"material", area, graph) as GaeaMaterial
	var rng := define_rng(graph)

	if not is_instance_valid(material):
		_log_error("Invalid material provided", graph, graph.resources.find(self))
		return grid

	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		material = _get_arg(&"material", area, graph)
		_log_error(
			"Recursive limit reached (%d): Invalid material provided at %s" % [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path],
			graph,
			graph.resources.find(self)
		)
		return grid

	for cell in grid_data:
		if _passes_mapping(grid_data, cell, area, graph):
			grid.set(cell, material.execute_sample(rng, grid_data.get(cell)))

	return grid


## Should be overriden and return [code]true[/code] if the cell at [param cell] should be mapped to [param material] in the output.
@abstract
func _passes_mapping(grid_data: Dictionary, cell: Vector3i, _area: AABB, _graph: GaeaGraph) -> bool
