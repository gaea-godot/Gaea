@tool
extends GaeaNodeResource


func get_data(_passed_data:Array[Dictionary], output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:
	log_data(output_port, generator_data)
	
	var grid: Dictionary[Vector3i, float]
	var value: float = get_arg("value", generator_data)
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				grid[Vector3i(x, y, z)] = value
	return grid
