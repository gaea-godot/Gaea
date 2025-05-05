@tool
extends GaeaNodeFilter
class_name GaeaNodeThresholdFilter
## Filters [param data] to only the cells of a value in [param range].


func _get_title() -> String:
	return "ThresholdFilter"


func _get_description() -> String:
	return "Filters [param data] to only the cells of a value in [param range]."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"range"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"range": return GaeaValue.Type.RANGE
	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, graph: GaeaGraph) -> bool:
	var range_value: Dictionary = _get_arg(&"range", area, graph)
	var cell_value = input_data.get(cell)
	return cell_value >= range_value.get("min", 0.0) and cell_value <= range_value.get("max", 0.0)
