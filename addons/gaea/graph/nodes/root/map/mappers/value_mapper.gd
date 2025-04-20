@tool
extends GaeaNodeMapper
class_name GaeaNodeValueMapper
## Maps every cell in [param data] equal to [param value] to [param material].
##
## Uses [method @GlobalScope.is_equal_approx] to avoid floating point precision problems.


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var value: float = _get_arg(&"value", area, generator_data)
	return is_equal_approx(grid_data.get(cell), value)
