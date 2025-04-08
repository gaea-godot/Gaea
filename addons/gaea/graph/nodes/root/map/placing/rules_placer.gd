@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0, 1]

func get_data(passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	log_data(_output_port, generator_data)

	var grid_data: Dictionary = passed_data[0]
	var material: GaeaMaterial = passed_data[1].get("value", null)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	var rules: Dictionary = get_arg("rules", generator_data)

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var place: bool = true
				var cell: Vector3i = Vector3i(x, y, z)
				for offset: Vector2i in rules:
					var offset_3d: Vector3i = Vector3i(offset.x, offset.y, 0)
					if _is_point_outside_area(area, cell + offset_3d):
						place = false
						break

					if (grid_data.get(cell + offset_3d) != null) != rules.get(offset):
						place = false
						break
				if place:
					grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return grid
