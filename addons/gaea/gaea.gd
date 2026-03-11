@tool
extends EditorPlugin


func _enable_plugin() -> void:
	if Engine.is_editor_hint():
		EditorInterface.set_plugin_enabled("gaea/editor", true)
		EditorInterface.set_plugin_enabled("gaea/runtime", true)


func _disable_plugin() -> void:
	if Engine.is_editor_hint():
		EditorInterface.set_plugin_enabled("gaea/editor", false)
		EditorInterface.set_plugin_enabled("gaea/runtime", false)
