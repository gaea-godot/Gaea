@tool
extends GaeaNodeResource
class_name GaeaNodeMapper
## Abstract class used for mapper nodes. Can be overriden to customize behavior,
## otherwise maps all non-empty cells in [param data] to [param material].


func _get_required_params() -> Array[StringName]:
	return [&"data", &"material"]


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data = _get_arg(&"data", area, generator_data)
	var material: GaeaMaterial = _get_arg(&"material", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in grid_data:
		if is_instance_valid(material) and _passes_mapping(grid_data, cell, area, generator_data):
			grid[cell] = material.get_resource()

	return output_port.return_value(grid)


@warning_ignore("unused_parameter")
func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	return grid_data.get(cell) != null
