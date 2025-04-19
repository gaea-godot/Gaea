@tool
extends "basic_mapper.gd"


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var range_value: Dictionary = get_arg(&"range", area, generator_data)
	var cell_value = grid_data.get(cell)
	return cell_value >= range_value.get("min", 0.0) and cell_value <= range_value.get("max", 0.0)
