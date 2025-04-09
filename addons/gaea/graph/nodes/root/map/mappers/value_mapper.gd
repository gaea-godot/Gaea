@tool
extends "res://addons/gaea/graph/nodes/root/map/mappers/basic_mapper.gd"


func _passes_mapping(passed_data: Array[Dictionary], cell: Vector3i, generator_data: GaeaData) -> bool:
	var value: float = get_arg("value", generator_data)
	return passed_data[0].get(cell) == value
