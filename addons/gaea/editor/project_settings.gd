@tool
class_name GaeaProjectSettings
extends RefCounted


const CUSTOM_NODES_PATH := "gaea/nodes/custom_nodes_path"


func add_settings() -> void:
	_add_setting(CUSTOM_NODES_PATH, "", {"type": TYPE_STRING, "hint": PROPERTY_HINT_DIR})


func _add_setting(key: String, default_value: Variant, property_info: Dictionary) -> void:
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, default_value)
	ProjectSettings.set_initial_value(key, default_value)
	property_info.set("name", key)
	ProjectSettings.add_property_info(property_info)


func remove_settings() -> void:
	# Remove this setting that was added in previous versions, just in case.
	if ProjectSettings.has_setting("gaea/custom_nodes_path"):
		ProjectSettings.clear("gaea/custom_nodes_path")

	if ProjectSettings.has_setting(CUSTOM_NODES_PATH):
		ProjectSettings.clear(CUSTOM_NODES_PATH)


static func get_custom_nodes_path() -> String:
	return ProjectSettings.get_setting(CUSTOM_NODES_PATH, "")
