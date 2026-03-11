@tool
class_name GaeaNodeVector3Parameter
extends GaeaNodeParameter
## [Vector3] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_VECTOR3


func _get_title() -> String:
	return "Vector3Parameter"


func _get_description() -> String:
	return "[code]Vector3[/code] parameter editable in the inspector."
