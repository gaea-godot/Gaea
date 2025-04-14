@tool
class_name GaeaEditorSettings
extends RefCounted


const LINE_CURVATURE := "gaea/graph/line_curvature"
const LINE_THICKNESS := "gaea/graph/line_thickness"
const MINIMAP_OPACITY := "gaea/graph/minimap_opacity"
const GRID_PATTERN := "gaea/graph/grid_pattern"
const OUTPUT_TITLE_COLOR := "gaea/graph/output_title_color"
const COLOR_BASE := "gaea/graph/slot_colors/%s"
const ICON_BASE := "gaea/graph/slot_icons/%s"
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
	_add_setting(LINE_THICKNESS, 4.0, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,100.0"
	})
	_add_setting(MINIMAP_OPACITY, 0.85, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0"
	})
	_add_setting(GRID_PATTERN, 1, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Lines,Dots"
	})

	_add_setting(OUTPUT_TITLE_COLOR, Color("632639"), {"type": TYPE_COLOR, "hint": PROPERTY_HINT_COLOR_NO_ALPHA})

	for slot_type: GaeaGraphNode.SlotTypes in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaGraphNode.get_color_from_type(slot_type),
			{
				"type": TYPE_COLOR,
				"hint": PROPERTY_HINT_COLOR_NO_ALPHA
			}
		)


	for slot_type: GaeaGraphNode.SlotTypes in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaGraphNode.get_icon_from_type(slot_type).resource_path,
			{
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_FILE,
				"hint_string": "*.png,*.jpg,*.svg"
			}
		)


func _add_setting(key: String, default_value: Variant, property_info: Dictionary) -> void:
	if not editor_settings.has_setting(key):
		editor_settings.set_setting(key, default_value)
	editor_settings.set_initial_value(key, default_value, false)
	property_info.set("name", key)
	editor_settings.add_property_info(property_info)


static func get_configured_output_color() -> Color:
	return EditorInterface.get_editor_settings().get_setting(OUTPUT_TITLE_COLOR)


static func get_configured_color_for_slot_type(slot_type: GaeaGraphNode.SlotTypes) -> Color:
	if slot_type == GaeaGraphNode.SlotTypes.NULL:
		return Color.WHITE
	return EditorInterface.get_editor_settings().get_setting(COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type))


static func get_configured_icon_for_slot_type(slot_type: GaeaGraphNode.SlotTypes) -> Texture:
	if slot_type == GaeaGraphNode.SlotTypes.NULL:
		return null

	var path: String = EditorInterface.get_editor_settings().get_setting(ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type))
	if path.is_empty():
		return preload("res://addons/gaea/assets/slots/circle.svg")
	var loaded: Object = load(path)
	if loaded is Texture:
		return loaded
	return preload("res://addons/gaea/assets/slots/circle.svg")


static func get_line_curvature() -> float:
	return EditorInterface.get_editor_settings().get_setting(LINE_CURVATURE)


static func get_line_thickness() -> float:
	return EditorInterface.get_editor_settings().get_setting(LINE_THICKNESS)


static func get_minimap_opacity() -> float:
	return EditorInterface.get_editor_settings().get_setting(MINIMAP_OPACITY)


static func get_grid_pattern() -> int:
	return EditorInterface.get_editor_settings().get_setting(GRID_PATTERN)
