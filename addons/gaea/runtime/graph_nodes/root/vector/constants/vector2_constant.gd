@tool
class_name GaeaNodeVector2Constant
extends GaeaNodeConstant
## [Vector2] constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.VECTOR2


func _get_title() -> String:
	return "Vector2Constant"


func _get_description() -> String:
	return "[code]Vector2[/code] constant."
