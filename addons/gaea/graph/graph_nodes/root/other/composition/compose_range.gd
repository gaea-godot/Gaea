@tool
class_name GaeaNodeComposeRange
extends GaeaNodeResource
## Composes a range value from 2 numbers, [param min] and [param max].
##
## Ranges internally have the following format:
## [codeblock]
## {
##     min: float,
##     max: float
## }
## [/codeblock]
## See [enum GaeaValue.Type].


func _get_title() -> String:
	return "ComposeRange"


func _get_description() -> String:
	return "Composes a range value from 2 numbers, [param min] and [param max]."


func _get_arguments_list() -> Array[StringName]:
	return [&"min", &"max"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	return 0.0 if arg_name == &"min" else 1.0


func _get_output_ports_list() -> Array[StringName]:
	return [&"composed_range"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.RANGE


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Dictionary[String, float]:
	return {
		"min": _get_arg(&"min", graph, pouch),
		"max": _get_arg(&"max", graph, pouch),
	}
