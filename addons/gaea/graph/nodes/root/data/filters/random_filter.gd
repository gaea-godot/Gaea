@tool
extends "res://addons/gaea/graph/nodes/root/data/filters/filter.gd"


func _passes_filter(_passed_data: Dictionary, _cell: Vector3i, generator_data: GaeaData) -> bool:
	var chance: float = float(get_arg("chance", generator_data)) / 100.0
	return randf() <= chance
