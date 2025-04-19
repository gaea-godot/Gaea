@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	assert(output_port.name == &"data")

	var grid: Dictionary[Vector3i, float]
	var value: float = get_arg(&"value", area, generator_data)
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				grid[Vector3i(x, y, z)] = value
	return output_port.return_value(grid)
