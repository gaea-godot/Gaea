@tool
class_name GaeaNodeCurveParameter
extends GaeaNodeParameter
## [GaeaCurve] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_OBJECT


func _get_property_hint() -> PropertyHint:
	return PROPERTY_HINT_RESOURCE_TYPE


func _get_property_hint_string() -> String:
	return "GaeaCurve"


func _get_title() -> String:
	return "CurveParameter"


func _get_description() -> String:
	return "GaeaCurve parameter editable in the inspector."
