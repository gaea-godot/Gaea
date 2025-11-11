@tool
class_name GaeaPanel
extends Control


@export var main_editor: GaeaMainEditor
@export var graph_edit: GaeaGraphEdit
@export var file_list: GaeaFileList

var plugin: GaeaEditorPlugin

static func instantiate() -> Node:
	return load("uid://dngytsjlmkfg7").instantiate()


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	main_editor.panel_popout_request.connect(_on_panel_popout_request)


#region Popout Panel Window
func _on_panel_popout_request() -> void:
	graph_edit.set_window_popout_button_visible(false)
	var window: Window = Window.new()
	window.min_size = get_combined_minimum_size()
	window.size = size
	window.title = "Gaea - Godot Engine"
	window.close_requested.connect(_on_window_close_requested.bind(get_parent(), window))

	var margin_container: MarginContainer = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel: Panel = Panel.new()
	panel.add_theme_stylebox_override(
		&"panel",
		EditorInterface.get_base_control().get_theme_stylebox(&"PanelForeground", &"EditorStyles")
	)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index -= 1
	window.add_child(margin_container)
	margin_container.add_sibling(panel)

	var margin: int = get_theme_constant(&"base_margin", &"Editor")
	margin_container.add_theme_constant_override(&"margin_top", margin)
	margin_container.add_theme_constant_override(&"margin_bottom", margin)
	margin_container.add_theme_constant_override(&"margin_left", margin)
	margin_container.add_theme_constant_override(&"margin_right", margin)

	window.position = global_position as Vector2i + DisplayServer.window_get_position()

	reparent(margin_container, false)

	EditorInterface.get_base_control().add_child(window)
	window.popup()


func _on_window_close_requested(original_parent: Control, window: Window) -> void:
	graph_edit.set_window_popout_button_visible(true)
	reparent(original_parent, false)
	window.queue_free()
#endregion
