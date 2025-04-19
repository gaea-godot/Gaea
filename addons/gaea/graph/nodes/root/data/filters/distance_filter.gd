@tool
extends "filter.gd"


@warning_ignore("unused_parameter")
func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var point: Vector3 = get_arg(&"to_point", area, generator_data)
	var distance_range: Dictionary = get_arg(&"distance_range", area, generator_data)
	var distance: float = Vector3(cell).distance_squared_to(point)
	return distance >= distance_range.get("min", -INF) ** 2 and distance <= distance_range.get("max", INF) ** 2
