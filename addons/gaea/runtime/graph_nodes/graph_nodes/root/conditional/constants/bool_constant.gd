@tool
class_name GaeaNodeBoolConstant
extends GaeaNodeConstant
## [bool] constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.BOOLEAN


func _get_title() -> String:
	return "BoolConstant"


func _get_description() -> String:
	return "[code]bool[/code] constant."
