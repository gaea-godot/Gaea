@tool
extends GaeaNodeResource


func _get_required_params() -> Array[StringName]:
	return [&"data"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	assert(output_port.name == &"border")

	var neighbors: Array[Vector2i] = get_arg(&"neighbors", area, generator_data)
	var inside: bool = get_arg(&"inside", area, generator_data)
	var input_data: Dictionary[Vector3i, float] = get_arg(&"data", area, generator_data)

	var border: Dictionary[Vector3i, float] = {}
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if (inside and input_data.get(cell) == null) or (not inside and input_data.get(cell) != null):
					continue

				for n: Vector2i in neighbors:
					if not inside:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if input_data.get(neighboring_cell) != null:
							border.set(cell, 1)
							break
					else:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if input_data.get(neighboring_cell) == null:
							border.set(cell, 1)
							break

	return output_port.return_value(border)
