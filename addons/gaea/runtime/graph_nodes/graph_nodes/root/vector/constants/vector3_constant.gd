@tool
class_name GaeaNodeVector3Constant
extends GaeaNodeConstant
## [Vector3] constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.VECTOR3


func _get_title() -> String:
	return "Vector3Constant"


func _get_description() -> String:
	return "[code]Vector3[/code] constant."
