@tool
class_name GaeaEditorSettings
extends RefCounted

const CIRCLE := preload("uid://dqob6v3dudlri")

const LINE_CURVATURE := "gaea/graph/line_curvature"
const LINE_CURVATURE_DEFAULT := 0.5
const LINE_THICKNESS := "gaea/graph/line_thickness"
const LINE_THICKNESS_DEFAULT := 4.0
const MINIMAP_OPACITY := "gaea/graph/minimap_opacity"
const MINIMAP_OPACITY_DEFAULT := 0.85
const GRID_PATTERN := "gaea/graph/grid_pattern"
const GRID_PATTERN_DEFAULT := 1
const PREVIEW_RESOLUTION := "gaea/graph/preview/preview_resolution"
const PREVIEW_RESOLUTION_DEFAULT := 64
const PREVIEW_MAX_SIMULATION_SIZE := "gaea/graph/preview/max_simulation_size"
const PREVIEW_MAX_SIMULATION_SIZE_DEFAULT := 128
const OUTPUT_TITLE_COLOR := "gaea/graph/output_title_color"
const OUTPUT_TITLE_COLOR_DEFAULT := Color("632639")
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
	GaeaValue.Type.SAMPLE: "sample",
	GaeaValue.Type.MAP: "map",
}

var editor_settings: EditorSettings


func add_settings() -> void:
	var editor_interface = Engine.get_singleton("EditorInterface")
	editor_settings = editor_interface.get_editor_settings()
	_add_setting(LINE_CURVATURE, LINE_CURVATURE_DEFAULT, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0"
	})
	_add_setting(LINE_THICKNESS, LINE_THICKNESS_DEFAULT, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,100.0"
	})
	_add_setting(MINIMAP_OPACITY, MINIMAP_OPACITY_DEFAULT, {
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,1.0"
	})
	_add_setting(GRID_PATTERN,GRID_PATTERN_DEFAULT, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Lines,Dots"
	})
	_add_setting(PREVIEW_RESOLUTION, PREVIEW_RESOLUTION_DEFAULT, {
		"type": TYPE_INT
	})
	_add_setting(PREVIEW_MAX_SIMULATION_SIZE, PREVIEW_MAX_SIMULATION_SIZE_DEFAULT, {
		"type": TYPE_INT
	})

	_add_setting(
		OUTPUT_TITLE_COLOR,
		OUTPUT_TITLE_COLOR_DEFAULT,
		{"type": TYPE_COLOR, "hint": PROPERTY_HINT_COLOR_NO_ALPHA}
	)


	for slot_type: GaeaValue.Type in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			COLOR_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaValue.get_default_color(slot_type),
			{"type": TYPE_COLOR, "hint": PROPERTY_HINT_COLOR_NO_ALPHA}
		)

	for slot_type: GaeaValue.Type in CONFIGURABLE_SLOT_COLORS.keys():
		_add_setting(
			ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(slot_type),
			GaeaValue.get_default_slot_icon(slot_type).resource_path,
			{"type": TYPE_STRING, "hint": PROPERTY_HINT_FILE, "hint_string": "*.png,*.jpg,*.svg"}
		)

	# Transfer data to sample since [#473](https://github.com/gaea-godot/gaea/pull/473).
	_transfer_and_erase_setting(COLOR_BASE % "data", COLOR_BASE % "sample")
	_transfer_and_erase_setting(ICON_BASE % "data", ICON_BASE % "sample")


func _add_setting(key: String, default_value: Variant, property_info: Dictionary) -> void:
	if not editor_settings.has_setting(key):
		editor_settings.set_setting(key, default_value)
	editor_settings.set_initial_value(key, default_value, false)
	property_info.set("name", key)
	editor_settings.add_property_info(property_info)


func _transfer_and_erase_setting(old_key: String, new_key: String) -> void:
	if editor_settings.has_setting(old_key):
		editor_settings.set_setting(new_key, editor_settings.get_setting(old_key))
		editor_settings.erase(old_key)


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
		return CIRCLE
	var editor_interface = Engine.get_singleton("EditorInterface")
	var settings = editor_interface.get_editor_settings()
	var setting_path = ICON_BASE % CONFIGURABLE_SLOT_COLORS.get(value_type)
	if settings.has_setting(setting_path):
		var loaded: Object = load(settings.get_setting(setting_path))
		if loaded is Texture:
			return loaded
	return CIRCLE


static func get_line_curvature() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(LINE_CURVATURE):
		return editor_interface.get_editor_settings().get_setting(LINE_CURVATURE)
	return LINE_CURVATURE_DEFAULT


static func get_line_thickness() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(LINE_THICKNESS):
		return editor_interface.get_editor_settings().get_setting(LINE_THICKNESS)
	return LINE_THICKNESS_DEFAULT


static func get_minimap_opacity() -> float:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(MINIMAP_OPACITY):
		return editor_interface.get_editor_settings().get_setting(MINIMAP_OPACITY)
	return MINIMAP_OPACITY_DEFAULT


static func get_grid_pattern() -> int:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(GRID_PATTERN):
		return editor_interface.get_editor_settings().get_setting(GRID_PATTERN)
	return GRID_PATTERN_DEFAULT


static func get_preview_resolution() -> int:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(PREVIEW_RESOLUTION):
		return editor_interface.get_editor_settings().get_setting(PREVIEW_RESOLUTION)
	return PREVIEW_RESOLUTION_DEFAULT


static func get_preview_max_simulation_size() -> int:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface.get_editor_settings().has_setting(PREVIEW_MAX_SIMULATION_SIZE):
		return editor_interface.get_editor_settings().get_setting(PREVIEW_MAX_SIMULATION_SIZE)
	return PREVIEW_MAX_SIMULATION_SIZE_DEFAULT


static func get_file_list_action_shortcut(action: GaeaFileList.Action, shortcut_key: Key) -> Shortcut:
	return _get_shortcut("file_list", GaeaFileList.Action.find_key(action), shortcut_key)


static func get_node_action_shortcut(action: GaeaGraphEdit.Action, shortcut_key: Key) -> Shortcut:
	return _get_shortcut("node_context_menu", GaeaGraphEdit.Action.find_key(action), shortcut_key)


static func _get_shortcut(category: String, action_key: String, shortcut_key: Key) -> Shortcut:
	var editor_interface = Engine.get_singleton("EditorInterface")
	var shortcut_path = StringName(("gaea/%s - %s" % [category.capitalize(), action_key.capitalize()]))

	if editor_interface.get_editor_settings().has_shortcut(shortcut_path):
		return editor_interface.get_editor_settings().get_shortcut(shortcut_path)

	var shortcut = Shortcut.new()
	var key_event = InputEventKey.new()
	key_event.keycode = shortcut_key & KeyModifierMask.KEY_CODE_MASK
	key_event.command_or_control_autoremap = shortcut_key & KeyModifierMask.KEY_MASK_CMD_OR_CTRL
	key_event.alt_pressed = shortcut_key & KeyModifierMask.KEY_MASK_ALT
	key_event.shift_pressed = shortcut_key & KeyModifierMask.KEY_MASK_SHIFT
	shortcut.events = [key_event]

	editor_interface.get_editor_settings().add_shortcut(shortcut_path, shortcut)

	return shortcut
