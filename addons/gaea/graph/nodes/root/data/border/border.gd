@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0]

func get_data(passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:
	log_data(_output_port, generator_data)

	var neighbors: Array[Vector2i] = get_arg("neighbors", generator_data)
	var inside: bool = get_arg("inside", generator_data)

	var border: Dictionary[Vector3i, float] = {}
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if (inside and passed_data[0].get(cell) == null) or (not inside and passed_data[0].get(cell) != null):
					continue

				for n: Vector2i in neighbors:
					if not inside:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if passed_data[0].get(neighboring_cell) != null:
							border.set(cell, 1)
							break
					else:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if passed_data[0].get(neighboring_cell) == null:
							border.set(cell, 1)
							break

	return border
