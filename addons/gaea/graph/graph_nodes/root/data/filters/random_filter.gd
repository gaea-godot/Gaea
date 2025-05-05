@tool
extends GaeaNodeFilter
class_name GaeaNodeRandomFilter
## Randomly filters [param data] to only the cells that pass the [param chance] check.


func _get_title() -> String:
	return "RandomFilter"


func _get_description() -> String:
	return "Filters [param data] to only the cells that pass the [param chance] check."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"chance"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"chance": return GaeaValue.Type.INT
	return super(arg_name)


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"chance": return 50
	return super(arg_name)


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	match arg_name:
		&"chance": return {"suffix": "%", "min": 0, "max": 100}
	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _passes_filter(_input_data: Dictionary, _cell: Vector3i, area: AABB, graph: GaeaGraph) -> bool:
	var chance: float = float(_get_arg(&"chance", area, graph)) / 100.0
	return randf() <= chance
