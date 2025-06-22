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
	GaeaValue.Type.BOOLEAN: "bool",
	GaeaValue.Type.INT: "int",
	GaeaValue.Type.FLOAT: "float",
	GaeaValue.Type.VECTOR2: "vector_2",
	GaeaValue.Type.VECTOR2I: "vector_2i",
	GaeaValue.Type.VECTOR3: "vector_3",
	GaeaValue.Type.VECTOR3I: "vector_3i",
	GaeaValue.Type.RANGE: "range",
	GaeaValue.Type.MATERIAL: "material",
	GaeaValue.Type.TEXTURE: "texture",
	GaeaValue.Type.DATA: "data",
	GaeaValue.Type.MAP: "map",
}

var editor_settings


func add_settings() -> void:
	var editor_interface = Engine.get_singleton("EditorInterface")
	editor_settings = editor_interface.get_editor_settings()
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

	for slot_type: GaeaValue.Type in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaValue.get_default_color(slot_type),
			{
				"type": TYPE_COLOR,
				"hint": PROPERTY_HINT_COLOR_NO_ALPHA
			}
		)

	for slot_type: GaeaValue.Type in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaValue.get_default_slot_icon(slot_type).resource_path,
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
	var editor_interface = Engine.get_singleton("EditorInterface")
	return editor_interface.get_editor_settings().get_setting(OUTPUT_TITLE_COLOR)


static func get_configured_color_for_value_type(value_type: GaeaValue.Type) -> Color:
	if not CONFIGURABLE_SLOT_COLORS.has(value_type):
		return Color.WHITE
	var editor_interface = Engine.get_singleton("EditorInterface")
	var settings = editor_interface.get_editor_settings()
	var setting_path = COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(value_type)
	if settings.has_setting(setting_path):
		return settings.get_setting(setting_path)
	return Color.WHITE


static func get_configured_icon_for_value_type(value_type: GaeaValue.Type) -> Texture:
	if not CONFIGURABLE_SLOT_COLORS.has(value_type):
		return preload("res://addons/gaea/assets/slots/circle.svg")
	var editor_interface = Engine.get_singleton("EditorInterface")
	var settings = editor_interface.get_editor_settings()
	var setting_path = ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(value_type)
	if settings.has_setting(setting_path):
		var loaded: Object = load(settings.get_setting(setting_path))
		if loaded is Texture:
			return loaded
	return preload("res://addons/gaea/assets/slots/circle.svg")


static func get_line_curvature() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	return editor_interface.get_editor_settings().get_setting(LINE_CURVATURE)


static func get_line_thickness() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	return editor_interface.get_editor_settings().get_setting(LINE_THICKNESS)


static func get_minimap_opacity() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	return editor_interface.get_editor_settings().get_setting(MINIMAP_OPACITY)


static func get_grid_pattern() -> int:
	var editor_interface = Engine.get_singleton("EditorInterface")
	return editor_interface.get_editor_settings().get_setting(GRID_PATTERN)
