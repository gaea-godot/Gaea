@tool
class_name GaeaNodeVector2Parameter
extends GaeaNodeParameter
## [Vector2] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_VECTOR2


func _get_title() -> String:
	return "Vector2Parameter"


func _get_description() -> String:
	return "[code]Vector2[/code] parameter editable in the inspector."
