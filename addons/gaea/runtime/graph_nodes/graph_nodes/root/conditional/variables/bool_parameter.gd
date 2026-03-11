@tool
class_name GaeaNodeBoolParameter
extends GaeaNodeParameter
## [bool] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_BOOL


func _get_title() -> String:
	return "BoolParameter"


func _get_description() -> String:
	return "[code]bool[/code] parameter editable in the inspector."
