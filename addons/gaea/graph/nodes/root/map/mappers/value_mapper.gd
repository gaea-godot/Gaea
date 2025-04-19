@tool
extends "basic_mapper.gd"


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var value: float = get_arg(&"value", area, generator_data)
	return is_equal_approx(grid_data.get(cell), value)
