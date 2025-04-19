@tool
extends GaeaNodeResource

func _get_required_params() -> Array[StringName]:
	return [&"data"]

@warning_ignore("unused_parameter")
func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var input_grid = get_arg(&"data", area, generator_data)
	var grid: Dictionary = {}

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if input_grid.get(cell) == null:
					grid.set(cell, 1.0)

	return output_port.return_value(grid)
