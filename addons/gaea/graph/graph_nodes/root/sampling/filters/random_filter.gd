@tool
class_name GaeaNodeRandomFilter
extends GaeaNodeFilter
## Randomly filters [param sample] to only the cells that pass the [param chance] check.


func _get_title() -> String:
	return "RandomFilter"


func _get_description() -> String:
	return "Filters [param sample] to only the cells that pass the [param chance] check."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"chance"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"chance":
			return GaeaValue.Type.INT
	return super(arg_name)


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"chance":
			return 50
	return super(arg_name)


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	match arg_name:
		&"chance":
			return {"suffix": "%", "min": 0, "max": 100}
	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _passes_filter(
	_input_sample: GaeaValue.GridType, _cell: Vector3i, args: Dictionary[StringName, Variant]
) -> bool:
	var chance: float = float(args.get(&"chance")) / 100.0
	return rng.randf() <= chance
