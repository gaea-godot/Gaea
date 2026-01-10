@tool
extends EditorPlugin

const DocumentationToolkit = preload("uid://bxanwt5o3b0ng")

var _panel: Control


func _enter_tree() -> void:
	_panel = DocumentationToolkit.instantiate()
	add_control_to_bottom_panel(_panel, "Gaea Documentation Toolkit")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(_panel)
