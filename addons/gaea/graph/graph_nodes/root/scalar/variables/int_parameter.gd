@tool
class_name GaeaNodeIntParameter
extends GaeaNodeParameter
## [int] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_INT


func _get_title() -> String:
	return "IntParameter"


func _get_description() -> String:
	return "[code]int[/code] parameter editable in the inspector."
