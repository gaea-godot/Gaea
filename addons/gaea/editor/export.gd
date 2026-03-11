@tool

class_name GaeaEditorExportPlugin
extends EditorExportPlugin


func _get_name() -> String:
	# The name should be < "GDScript" or the skips won't works.
	# See https://github.com/godotengine/godot/issues/93487.
	# Docs: "The plugins are sorted by name before exporting".
	return "GDA_Gaea"


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if path.begins_with("res://addons/gaea/editor/"):
		skip()
		return
