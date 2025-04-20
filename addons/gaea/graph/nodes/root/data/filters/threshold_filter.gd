@tool
extends GaeaNodeFilter
class_name GaeaNodeThresholdFilter
## Filters [param data] to only the cells of a value in [param range].


func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var range_value: Dictionary = _get_arg(&"range", area, generator_data)
	var cell_value = input_data.get(cell)
	return cell_value >= range_value.get("min", 0.0) and cell_value <= range_value.get("max", 0.0)
