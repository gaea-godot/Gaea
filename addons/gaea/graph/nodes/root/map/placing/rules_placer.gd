@tool
extends GaeaNodeResource

func _get_required_params() -> Array[StringName]:
	return [&"data", &"material"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grid_data: Dictionary = get_arg(&"data", area, generator_data)
	var material: GaeaMaterial = get_arg(&"material", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	var rules: Dictionary = get_arg(&"rules", area, generator_data)

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

	return output_port.return_value(grid)
