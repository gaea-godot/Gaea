@tool
extends "res://addons/gaea/graph/nodes/root/data/filters/filter.gd"


func _passes_filter(passed_data: Dictionary, cell: Vector3i, generator_data: GaeaData) -> bool:
	var range_value: Dictionary = get_arg("range", generator_data)
	var cell_value = passed_data.get(cell)
	return cell_value >= range_value.get("min", 0.0) and cell_value <= range_value.get("max", 0.0)
