@tool
class_name GaeaNodeBasicMapper
extends GaeaNodeMapper
## Maps all non-empty cells in [param reference] to [param material].


func _get_title() -> String:
	return "Mapper"


func _get_description() -> String:
	return "Maps all non-empty cells in [param reference] to [param material]."


func _passes_mapping(
	reference_sample: GaeaValue.Sample, cell: Vector3i, _args: Dictionary[StringName, Variant]
) -> bool:
	return reference_sample.has(cell)
