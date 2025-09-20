@tool
# class_name GaeaNode...Parameter
extends GaeaNodeParameter
## type parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_NIL


func _get_title() -> String:
	return "TypeParameter"


func _get_description() -> String:
	return "type parameter editable in the inspector."
