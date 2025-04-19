@tool
extends "filter.gd"


func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var chance: float = float(get_arg(&"chance", area, generator_data)) / 100.0
	return randf() <= chance
