@tool
@abstract
class_name GaeaNodeVectorBase
extends GaeaNodeResource
## Base class for vector operation nodes.

enum VectorType {
	VECTOR2 = GaeaValue.Type.VECTOR2,
	VECTOR3 = GaeaValue.Type.VECTOR3,
	VECTOR2I = GaeaValue.Type.VECTOR2I,
	VECTOR3I = GaeaValue.Type.VECTOR3I,
}


func _get_vector_type_name() -> String:
	return VectorType.find_key(get_enum_selection(0)).to_pascal_case()


func _get_enums_count() -> int:
	return 1


func _get_enum_options(enum_idx: int) -> Dictionary:
	match enum_idx:
		0:
			return VectorType
	return {}


func _get_enum_option_display_name(enum_idx: int, option_value: int) -> String:
	return super(enum_idx, option_value).replace(" ", "")


func _get_enum_option_icon(_enum_idx: int, option_value: int) -> Texture:
	return GaeaValue.get_display_icon(option_value)


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _is_integer_vector() -> bool:
	return get_enum_selection(0) in [VectorType.VECTOR2I, VectorType.VECTOR3I]
