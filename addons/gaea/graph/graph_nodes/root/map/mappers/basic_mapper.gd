@tool
extends GaeaNodeMapper
class_name GaeaNodeBasicMapper
## Maps all non-empty cells in [param data] to [param material].


func _get_title() -> String:
	return "Mapper"


func _get_description() -> String:
	return "Maps all non-empty cells in [param reference_data] to [param material]."


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, _area: AABB, _graph: GaeaGraph) -> bool:
	return grid_data.get(cell) != null
