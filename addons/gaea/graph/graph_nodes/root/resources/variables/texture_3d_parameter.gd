@tool
class_name GaeaNodeTexture3DParameter
extends GaeaNodeParameter
## [Texture3D] parameter editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_OBJECT
	
	
func _get_property_hint() -> PropertyHint:
	return PROPERTY_HINT_RESOURCE_TYPE


func _get_property_hint_string() -> String:
	return "Texture3D"


func _get_title() -> String:
	return "Texture3DParameter"


func _get_description() -> String:
	return "Texture3D parameter editable in the inspector."
