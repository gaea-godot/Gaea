@tool
extends EditorPlugin


var _custom_project_settings: GaeaProjectSettings


func _enter_tree() -> void:
	_custom_project_settings = GaeaProjectSettings.new()
	_custom_project_settings.add_settings()


func _exit_tree() -> void:
	_custom_project_settings.remove_settings()
