@tool
class_name GaeaPanel
extends Control

const LinkPopup = preload("uid://btt4eqjkp5pyf")

var plugin: GaeaEditorPlugin

@onready var graph_edit: GaeaGraphEdit = %GraphEdit



#region Built-in & Input
static func instantiate() -> Node:
	return load("uid://dngytsjlmkfg7").instantiate()


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	graph_edit.panel_popout_request.connect(_on_panel_popout_request)

	#_reload_node_tree_button.icon = preload("uid://crs5x6wghxmmb")
	#_reload_parameters_list_button.icon = preload("uid://cwg7oy4i2cbwq")

	#_duplicate_graph_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Duplicate", &"EditorIcons")
	#_window_popout_button.icon = EditorInterface.get_base_control().get_theme_icon(&"MakeFloating", &"EditorIcons")
	#_online_docs_button.icon = EditorInterface.get_base_control().get_theme_icon(&"ExternalLink", &"EditorIcons")
	#_create_node_panel.add_theme_stylebox_override(
	#	&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"panel", &"PopupPanel")
	#)


	#if not EditorInterface.is_multi_window_enabled():
	#	_window_popout_button.disabled = true
	#	_window_popout_button.tooltip_text = _get_multiwindow_support_tooltip_text()


#endregion


#region Buttons



func _on_reload_parameters_list_button_pressed() -> void:
	if false:
		return

	var existing_parameters: Array[String]
	for node in graph_edit.get_children():
		if node is not GaeaGraphNode:
			continue

		if node.resource is GaeaNodeParameter:
			existing_parameters.append(node.get_arg_value("name"))


	#for param in _selected_generator.data.get_parameter_list().keys():
	#	if param in existing_parameters:
	#		continue

	#	_selected_generator.data.remove_parameter(param)
	#_selected_generator.notify_property_list_changed()



#region Popout Panel Window
func _on_panel_popout_request() -> void:
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
	#_window_popout_button.hide()
	#_window_popout_separator.hide()


func _on_window_close_requested(original_parent: Control, window: Window) -> void:
	reparent(original_parent, false)
	window.queue_free()
	#_window_popout_button.show()
	#_window_popout_separator.show()
#endregion
