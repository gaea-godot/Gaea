@tool
class_name GaeaNodeIntConstant
extends GaeaNodeConstant
## [int] constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT


func _get_title() -> String:
	return "IntConstant"


func _get_description() -> String:
	return "[code]int[/code] constant."
