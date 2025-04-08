@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0]

func get_data(original_grid:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)

	var grid: Dictionary = {}

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if original_grid[0].get(cell) == null:
					grid.set(cell, 1.0)

	return grid
