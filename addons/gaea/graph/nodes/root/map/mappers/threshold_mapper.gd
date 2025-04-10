@tool
extends "res://addons/gaea/graph/nodes/root/map/mappers/basic_mapper.gd"


func _passes_mapping(passed_data: Array[Dictionary], cell: Vector3i, generator_data: GaeaData) -> bool:
	var range_value: Dictionary = get_arg("range", generator_data)
	var cell_value = passed_data[0].get(cell)
	return cell_value >= range_value.get("min", 0.0) and cell_value <= range_value.get("max", 0.0)
