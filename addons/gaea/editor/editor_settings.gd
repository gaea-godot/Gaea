@tool
class_name GaeaEditorSettings
extends RefCounted

const LINE_CURVATURE := "gaea/graph/line_curvature"
const COLOR_BASE := "gaea/graph/slot_colors/%s"
const CONFIGURABLE_SLOT_COLORS := {
	GaeaGraphNode.SlotTypes.DATA: "data",
	GaeaGraphNode.SlotTypes.MAP: "map",
	GaeaGraphNode.SlotTypes.NUMBER: "scalar",
	GaeaGraphNode.SlotTypes.VECTOR2: "vector_2",
	GaeaGraphNode.SlotTypes.VECTOR3: "vector_3",
	GaeaGraphNode.SlotTypes.RANGE: "range",
	GaeaGraphNode.SlotTypes.MATERIAL: "material",
	GaeaGraphNode.SlotTypes.GRADIENT: "gradient",
	GaeaGraphNode.SlotTypes.BOOL: "bool"
}

var editor_settings: EditorSettings


func add_settings() -> void:
	editor_settings = EditorInterface.get_editor_settings()
	_add_setting(LINE_CURVATURE, 0.5, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0"
	})


	for slot_type: GaeaGraphNode.SlotTypes in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaGraphNode.get_color_from_type(slot_type),
			{
				"type": TYPE_COLOR,
				"hint": PROPERTY_HINT_COLOR_NO_ALPHA
			}
		)


func _add_setting(key: String, default_value: Variant, property_info: Dictionary) -> void:
	if not editor_settings.has_setting(key):
		editor_settings.set_setting(key, default_value)
	editor_settings.set_initial_value(key, default_value, false)
	property_info.set("name", key)
	editor_settings.add_property_info(property_info)


static func get_configured_color_for_slot_type(slot_type: GaeaGraphNode.SlotTypes) -> Color:
	if slot_type == GaeaGraphNode.SlotTypes.NULL:
		return Color.WHITE
	return EditorInterface.get_editor_settings().get_setting(COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type))


static func get_line_curvature() -> float:
	return EditorInterface.get_editor_settings().get_setting(LINE_CURVATURE)
