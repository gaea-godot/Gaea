@tool
class_name GaeaNodeDistanceFilter
extends GaeaNodeFilter
## Filters [param sample] to only the cells at a distance from [param to_point] in [param distance_range].


func _get_title() -> String:
	return "DistanceFilter"


func _get_description() -> String:
	return "Filters [param sample] to only the cells at a distance from [param to_point] in [param distance_range]."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"to_point", &"distance_range"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"to_point":
			return GaeaValue.Type.VECTOR3
		&"distance_range":
			return GaeaValue.Type.RANGE
	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _passes_filter(
	_input_sample: GaeaValue.GridType, cell: Vector3i, args: Dictionary[StringName, Variant]
) -> bool:
	var point: Vector3 = args.get(&"to_point")
	var distance_range: Dictionary = args.get(&"distance_range")
	var distance: float = Vector3(cell).distance_squared_to(point)
	var is_further_than_min: bool = distance >= distance_range.get("min", -INF) ** 2
	var is_closer_than_max: bool = distance <= distance_range.get("max", INF) ** 2
	return is_further_than_min and is_closer_than_max
