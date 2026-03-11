@tool
class_name GaeaNodeFloatConstant
extends GaeaNodeConstant
## [float] constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_title() -> String:
	return "FloatConstant"


func _get_description() -> String:
	return "[code]float[/code] constant."
