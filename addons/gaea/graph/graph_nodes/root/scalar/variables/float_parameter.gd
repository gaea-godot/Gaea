@tool
class_name GaeaNodeFloatParameter
extends GaeaNodeParameter
## [float] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_FLOAT


func _get_title() -> String:
	return "FloatParameter"


func _get_description() -> String:
	return "[code]float[/code] parameter editable in the inspector."
