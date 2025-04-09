@tool
extends "res://addons/gaea/graph/nodes/root/map/mappers/basic_mapper.gd"


func _passes_mapping(passed_data: Dictionary, cell: Vector3i, generator_data: GaeaData) -> bool:
	var range: Dictionary = get_arg("range", generator_data)
	var value = passed_data.get(cell)
	return value >= range.get("min", 0.0) and value <= range.get("max", 0.0)
