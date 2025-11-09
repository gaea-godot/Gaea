@tool
extends AcceptDialog

const CONTRIBUTORS_LIST := "res://addons/gaea/contributors.txt"

@export var main_editor: GaeaMainEditor

@onready var _contributors_panel: PanelContainer = %ContributorsPanel
@onready var _main_vbox: VBoxContainer = %MainVBox
@onready var _contributors_v_box: VBoxContainer = %ContributorsVBox
@onready var _version_label: LinkButton = %VersionLabel


func initialize() -> void:
	if is_part_of_edited_scene():
		return

	var plugin: GaeaEditorPlugin = main_editor.gaea_panel.plugin
	_version_label.text = "Gaea %s" % plugin.get_plugin_version()
	_version_label.uri = "https://github.com/gaea-godot/gaea/releases/tag/%s" % plugin.get_plugin_version()
	_version_label.tooltip_text = _version_label.uri
	_contributors_panel.add_theme_stylebox_override(
		&"panel",
		EditorInterface.get_base_control().get_theme_stylebox(&"LaunchPadNormal", &"EditorStyles")
	)
	for child in _main_vbox.get_children():
		if child is not PanelContainer:
			continue
		child.add_theme_stylebox_override(
			&"panel",
			EditorInterface.get_base_control().get_theme_stylebox(&"Background", &"EditorStyles")
		)

	var contributors: Array[String]
	var file := FileAccess.open(CONTRIBUTORS_LIST, FileAccess.READ)
	while not file.eof_reached():
		contributors.append(file.get_line())
	contributors.sort()

	for contributor: String in contributors:
		if contributor.is_empty():
			continue
		var label := Label.new()
		label.text = contributor
		_contributors_v_box.add_child(label)


func _on_main_editor_about_popup_request() -> void:
	popup_centered()
	initialize()
