@tool
extends GaeaNodeFilter
class_name GaeaNodeRandomFilter
## Randomly filters [param data] to only the cells that pass the [param chance] check.


func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var chance: float = float(_get_arg(&"chance", area, generator_data)) / 100.0
	return randf() <= chance
