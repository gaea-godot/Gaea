@tool
extends GaeaNodeResource
class_name GaeaNodeMapper
## Abstract class used for mapper nodes. Can be overridden to customize behavior,
## otherwise maps all non-empty cells in [param data] to [param material].


func _get_title() -> String:
	return "Mapper"


func _get_description() -> String:
	return "Maps all non-empty cells in [param reference_data] to [param material]."


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


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data = _get_arg(&"reference_data", area, generator_data)
	var material: GaeaMaterial = _get_arg(&"material", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in grid_data:
		if is_instance_valid(material) and _passes_mapping(grid_data, cell, area, generator_data):
			grid[cell] = material.get_resource()

	return grid


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, _area: AABB, _generator_data: GaeaData) -> bool:
	return grid_data.get(cell) != null
