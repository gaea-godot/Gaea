@tool
extends GaeaNodeResource


func get_data(_passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var start: float = get_arg("start", generator_data)
	var end: float = get_arg("end", generator_data)
	var new_grid: Dictionary[Vector3i, float]

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			var i: float = x / float(area.size.x) * 2 - 1
			var j: float = y / float(area.size.y) * 2 - 1

			# Get closest to 1.
			var value: float = maxf(absf(i), absf(j))
			var falloff_value: float

			if value < start:
				falloff_value = 1.0
			elif value > end:
				falloff_value = 0.0
			else:
				falloff_value = smoothstep(1.0, 0.0, inverse_lerp(start, end, value))

			new_grid[Vector3i(x, y, 0)] = falloff_value

	return new_grid
