@tool
@abstract
class_name GaeaNodeConstant
extends GaeaNodeResource
## Generic class for [b]TypeConstant[/b] nodes. See [enum GaeaValue.Type].
##
## Accepts no inputs and has only one output, [param value].


func _get_arguments_list() -> Array[StringName]:
	return [&"value"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return get_type()


func _get_argument_display_name(_arg_name: StringName) -> String:
	return ""


func _get_argument_description(_arg_name: StringName) -> String:
	return "A %s constant." % GaeaValue.get_type_string(get_type())


func _has_input_slot(_arg_name: StringName) -> bool:
	return false


func _get_output_ports_list() -> Array[StringName]:
	return [&"constant"]


func _get_output_port_description(_output_name: StringName) -> String:
	return "Returns [param value]."


func _get_overridden_output_port_idx(_output_name: StringName) -> int:
	return 0


func _get_data(_output_port: StringName, pouch: GaeaGenerationPouch) -> Variant:
	return _get_arg(&"value", pouch)
