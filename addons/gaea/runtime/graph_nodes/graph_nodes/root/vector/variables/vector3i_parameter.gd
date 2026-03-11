@tool
class_name GaeaNodeVector3iParameter
extends GaeaNodeParameter
## [Vector3i] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_VECTOR3I


func _get_title() -> String:
	return "Vector3iParameter"


func _get_description() -> String:
	return "[code]Vector3i[/code] parameter editable in the inspector."
