@tool
class_name GaeaNodeVector2iParameter
extends GaeaNodeParameter
## [Vector2i] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_VECTOR2I


func _get_title() -> String:
	return "Vector2iParameter"


func _get_description() -> String:
	return "[code]Vector2i[/code] parameter editable in the inspector."
