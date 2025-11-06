@tool
class_name GaeaNodeValueMapper
extends GaeaNodeMapper
## Maps every cell in [param reference] equal to [param value] to [param material].
##
## Uses [method @GlobalScope.is_equal_approx] to avoid floating point precision problems.


func _get_title() -> String:
	return "ValueMapper"


func _get_description() -> String:
	return "Maps every cell of [param reference] equal to [param value] to [param material]."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"value"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"value":
			return GaeaValue.Type.FLOAT
	return super(arg_name)


func _passes_mapping(grid_data: GaeaValue.Sample, cell: Vector3i, area: AABB, graph: GaeaGraph) -> bool:
	var value: float = _get_arg(&"value", area, graph)
	return is_equal_approx(grid_data.get_cell(cell), value)
