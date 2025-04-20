@tool
extends GaeaNodeFilter
class_name GaeaNodeDistanceFilter
## Filters [member data] to only the cells at a distance
## from [member to_point] between [member min] and [member max].


@warning_ignore("unused_parameter")
func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var point: Vector3 = _get_arg(&"to_point", area, generator_data)
	var distance_range: Dictionary = _get_arg(&"distance_range", area, generator_data)
	var distance: float = Vector3(cell).distance_squared_to(point)
	return distance >= distance_range.get("min", -INF) ** 2 and distance <= distance_range.get("max", INF) ** 2
