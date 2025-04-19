@tool
extends GaeaNodeResource

func _get_required_params() -> Array[StringName]:
	return [&"data", &"material"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grid_data = get_arg(&"data", area, generator_data)
	var material: GaeaMaterial = get_arg(&"material", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in grid_data:
		if is_instance_valid(material) and _passes_mapping(grid_data, cell, area, generator_data):
			grid[cell] = material.get_resource()

	return output_port.return_value(grid)


@warning_ignore("unused_parameter")
func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	return grid_data.get(cell) != null
