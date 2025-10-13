@tool
extends Control

const _LinkPopup = preload("uid://btt4eqjkp5pyf")

var _selected_generator: GaeaGenerator = null: get = get_selected_generator
var _output_node: GaeaGraphNode
var is_loading = false

## Local position on [GraphEdit] for a node that may be created in the future.
var _node_creation_target: Vector2 = Vector2.ZERO
var plugin: EditorPlugin

@onready var _no_data: Control = $NoData
@onready var _editor: Control = $Editor
@onready var _graph_edit: GraphEdit = %GraphEdit
@onready var _create_node_popup: Window = %CreateNodePopup
@onready var _create_node_panel: Panel = %CreateNodePanel
@onready var _node_popup: PopupMenu = %NodePopup
@onready var _link_popup: _LinkPopup = %LinkPopup
@onready var _create_node_tree: Tree = %CreateNodeTree
@onready var _search_bar: LineEdit = %SearchBar
@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _reload_node_tree_button: Button = %ReloadNodeTreeButton
@onready var _reload_parameters_list_button: Button = %ReloadParametersListButton
@onready var _file_dialog: FileDialog = $FileDialog
@onready var _online_docs_button: Button = %OnlineDocsButton
@onready var _window_popout_separator: VSeparator = %WindowPopoutSeparator
@onready var _window_popout_button: Button = %WindowPopoutButton
@onready var _bottom_note_label: RichTextLabel = %BottomNote
@onready var _about_button: Button = %AboutButton
@onready var _about_window: AcceptDialog = $AboutWindow


#region Built-in & Input
func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_reload_node_tree_button.icon = preload("../assets/reload_tree.svg")
	_reload_parameters_list_button.icon = preload("../assets/reload_variables_list.svg")
	_save_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Save", &"EditorIcons")
	_load_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Load", &"EditorIcons")
	_window_popout_button.icon = EditorInterface.get_base_control().get_theme_icon(&"MakeFloating", &"EditorIcons")
	_online_docs_button.icon = EditorInterface.get_base_control().get_theme_icon(&"ExternalLink", &"EditorIcons")
	_create_node_panel.add_theme_stylebox_override(&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"panel", &"PopupPanel"))
	_about_button.icon = EditorInterface.get_base_control().get_theme_icon(&"NodeInfo", &"EditorIcons")
	_about_button.pressed.connect(_about_window.popup_centered)
	_about_window.plugin = plugin
	_about_window.initialize()

	if not EditorInterface.is_multi_window_enabled():
		_window_popout_button.disabled = true
		_window_popout_button.tooltip_text = _get_multiwindow_support_tooltip_text()

	var add_node_button = Button.new()
	add_node_button.text = "Add Node..."
	add_node_button.pressed.connect(_popup_create_node_menu_at_mouse)
	var container := _graph_edit.get_menu_hbox()
	container.add_child(add_node_button)
	container.move_child(add_node_button, 0)

	visibility_changed.connect(_on_visibility_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_bottom_note()


func _on_graph_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			# Check if we clicked on a connection
			var mouse_position = _graph_edit.get_local_mouse_position()
			var connection = _graph_edit.get_closest_connection_at_point(mouse_position, 10.0)
			if not connection.is_empty():
				_popup_link_context_menu_at_mouse(connection)
				return

			var _selected: Array = _graph_edit.get_selected()
			if _selected.is_empty():
				_popup_create_node_menu_at_mouse()
			else:
				_popup_node_context_menu_at_mouse(_selected)


func _on_visibility_changed() -> void:
	_graph_edit.set_connection_lines_curvature(GaeaEditorSettings.get_line_curvature())
	_graph_edit.set_grid_pattern(GaeaEditorSettings.get_grid_pattern())
	_graph_edit.set_connection_lines_thickness(GaeaEditorSettings.get_line_thickness())
	_graph_edit.set_minimap_opacity(GaeaEditorSettings.get_minimap_opacity())

#endregion


#region Saving and Loading
func populate(node: GaeaGenerator) -> void:
	await _remove_children()
	_output_node = null

	if is_instance_valid(_selected_generator) and _selected_generator.data_changed.is_connected(_on_data_changed):
		_selected_generator.data_changed.disconnect(_on_data_changed)

	_selected_generator = node
	_graph_edit.generator = node

	if not _selected_generator.data_changed.is_connected(_on_data_changed):
		_selected_generator.data_changed.connect(_on_data_changed)

	if node.data == null:
		_editor.hide()
		_no_data.show()
	else:
		_editor.show()
		_no_data.hide()
		if not _selected_generator.data.layer_count_modified.is_connected(_update_output_node):
			_selected_generator.data.layer_count_modified.connect(_update_output_node)
		_load_data.call_deferred()


func unpopulate() -> void:
	if is_instance_valid(_selected_generator):
		if is_instance_valid(_selected_generator.data) and _selected_generator.data.layer_count_modified.is_connected(_update_output_node):
			_selected_generator.data.layer_count_modified.disconnect(_update_output_node)
		if _selected_generator.data_changed.is_connected(_on_data_changed):
			_selected_generator.data_changed.disconnect(_on_data_changed)

	_selected_generator = null

	await _remove_children()


func _remove_children() -> void:
	for child in _graph_edit.get_children():
		if child is GraphElement:
			child.queue_free()
			await child.tree_exited


func _load_data() -> void:
	is_loading = true

	var has_output_node: bool = false
	for id in _selected_generator.data.get_ids():
		var saved_data = _selected_generator.data.get_node_data(id)
		if saved_data.is_empty():
			continue
		match saved_data.get(&"type", GaeaGraph.NodeType.NODE):
			GaeaGraph.NodeType.FRAME:
				var frame: GaeaGraphFrame = _load_frame(saved_data)
				frame.id = id
				frame.generator = _selected_generator
				_load_attached_elements.bind(saved_data.get(&"attached", []), frame.name).call_deferred()
			GaeaGraph.NodeType.NODE:
				var node: GaeaGraphNode = _load_node(_selected_generator.data.get_node(id), saved_data, id)

				if node.resource is GaeaNodeOutput:
					has_output_node = true
					_output_node = node


	if not has_output_node:
		_output_node = _add_node(GaeaNodeOutput.new(), Vector2.ZERO)

	_load_scroll_offset.call_deferred(
		_output_node.size * 0.5 - _graph_edit.get_rect().size * 0.5
	)
	
	# from_node and to_node are indexes in the resources array
	_load_connections.call_deferred(_selected_generator.data.get_all_connections())

	update_connections()
	set_deferred(&"is_loading", false)
	
	
func _load_scroll_offset(default_offset: Vector2) -> void:
	if is_nan(_selected_generator.data.scroll_offset.x):
		_selected_generator.data.scroll_offset = default_offset
	_graph_edit.set_scroll_offset(_selected_generator.data.scroll_offset)
	_graph_edit.set_zoom(_selected_generator.data.zoom)


func _load_connections(connections: Array[Dictionary]) -> void:
	for connection in connections:
		var from_node: GraphNode = _selected_generator.data.get_node(connection.from_node).node
		var to_node: GraphNode = _selected_generator.data.get_node(connection.to_node).node
		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			continue
		if to_node.get_input_port_count() <= connection.to_port:
			continue
		_graph_edit.connection_request.emit(from_node.name, connection.from_port, to_node.name, connection.to_port)


func _load_frame(frame_data: Dictionary) -> GaeaGraphFrame:
	var new_frame: GaeaGraphFrame = GaeaGraphFrame.new()
	_graph_edit.add_child(new_frame)
	new_frame.load_save_data(frame_data)
	return new_frame


func _load_node(resource: GaeaNodeResource, saved_data: Dictionary, id: int) -> GraphNode:
	var node: GaeaGraphNode = resource.get_scene().instantiate()
	resource.load_save_data(saved_data)
	if resource.get_scene_script() != null:
		node.set_script(resource.get_scene_script())

	node.resource = resource
	node.generator = get_selected_generator()
	node.remove_invalid_connections_requested.connect(_graph_edit.remove_invalid_connections)
	_graph_edit.add_child(node)
	node.resource.id = id

	if is_instance_valid(node):
		node.load_save_data.call_deferred(saved_data)

	return node


func _load_attached_elements(attached: Array, frame_name: StringName) -> void:
	for id: int in attached:
		var node_resource: GaeaNodeResource = _selected_generator.data.get_node(id)
		var node: GraphElement
		if not is_instance_valid(node_resource):
			var _graph_children := _graph_edit.get_children()
			var _attached_frame_idx := _graph_children.find_custom(
				func(child: Node) -> bool: return child is GaeaGraphFrame and child.id == id
			)
			if _attached_frame_idx != -1:
				node = _graph_children[_attached_frame_idx]
		else:
			node = node_resource.node

		if not is_instance_valid(node):
			continue

		_graph_edit.attach_graph_element_to_frame(node.name, frame_name)
		_graph_edit._on_element_attached_to_frame(node.name, frame_name)
#endregion


#region GaeaGraph
func _on_new_data_button_pressed() -> void:
	_selected_generator.data = GaeaGraph.new()


func _on_data_changed() -> void:
	_remove_children()
	populate(_selected_generator)
#endregion


#region Creating Nodes
func _popup_create_node_menu_at_mouse() -> void:
	_node_creation_target = _graph_edit.get_local_mouse_position()
	_create_node_popup.position = Vector2i(get_global_mouse_position())
	if not EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		_create_node_popup.position += get_window().position
	_clamp_popup_in_window(_create_node_popup, get_window())
	_create_node_popup.popup()
	_search_bar.grab_focus()
	_search_bar.select_all()


func _clamp_popup_in_window(popup: Window, main_window: Window) -> void:
	var window_rect = Rect2i(main_window.position, main_window.size)
	var inner_rect = Rect2i(popup.position, popup.size)
	if inner_rect.position.x < window_rect.position.x:
		popup.position.x = window_rect.position.x
	elif inner_rect.position.x + inner_rect.size.x > window_rect.position.x + window_rect.size.x:
		popup.position.x = window_rect.position.x + window_rect.size.x - inner_rect.size.x

	if inner_rect.position.y < window_rect.position.y:
		popup.position.y = window_rect.position.y
	elif inner_rect.position.y + inner_rect.size.y > window_rect.position.y + window_rect.size.y:
		popup.position.y = window_rect.position.y + window_rect.size.y - inner_rect.size.y


func _add_node(resource: GaeaNodeResource, local_grid_position: Vector2) -> GraphNode:
	var id := _selected_generator.data.add_node(resource, local_grid_position)

	var node: GaeaGraphNode = resource.get_scene().instantiate()
	if resource.get_scene_script() != null:
		node.set_script(resource.get_scene_script())

	if node is GaeaGraphNode:
		node.generator = get_selected_generator()
		node.remove_invalid_connections_requested.connect(_graph_edit.remove_invalid_connections)

	node.resource = resource
	node.position_offset = local_grid_position
	resource.id = id
	_graph_edit.add_child(node)

	return node


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_create_node_popup.hide()
	_add_node(resource.duplicate(), _graph_edit.local_to_grid(_node_creation_target))


func _on_tree_special_node_selected_for_creation(id: StringName) -> void:
	match id:
		&"frame":
			_add_frame()
	_create_node_popup.hide()


func _add_frame() -> void:
	var id: int = _selected_generator.data.add_frame(_graph_edit.local_to_grid(_node_creation_target))
	var node: GaeaGraphFrame = GaeaGraphFrame.new()
	node.generator = _selected_generator
	node.id = id
	node.position_offset = _graph_edit.local_to_grid(_node_creation_target)
	_graph_edit.add_child(node)


func _on_new_reroute_requested(connection: Dictionary) -> void:
	var resource: GaeaNodeReroute = GaeaNodeReroute.new()
	var from_node: GraphNode = _graph_edit.get_node(NodePath(connection.from_node))
	resource.type = from_node.get_output_port_type(connection.from_port) as GaeaValue.Type
	var reroute: GaeaGraphNode = _add_node(resource, Vector2.ZERO)

	var offset = - reroute.get_output_port_position(0)
	offset.y -= reroute.get_slot_custom_icon_right(0).get_size().y * 0.5
	reroute.set_position_offset(_graph_edit.local_to_grid(_node_creation_target, offset))

	_selected_generator.data.set_node_position(reroute.resource.id, reroute.position_offset)


	_graph_edit.disconnection_request.emit.call_deferred(
		connection.from_node, connection.from_port,
		connection.to_node, connection.to_port,
	)
	_graph_edit.connection_request.emit.call_deferred(
		connection.from_node, connection.from_port,
		reroute.name, 0,
	)
	_graph_edit.connection_request.emit.call_deferred(
		reroute.name, 0,
		connection.to_node, connection.to_port,
	)
#endregion


#region Popups
func _popup_node_context_menu_at_mouse(selected_nodes: Array) -> void:
	_node_popup.clear()
	_node_popup.populate(selected_nodes)
	_node_popup.position = Vector2i(get_global_mouse_position())
	if not EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		_node_popup.position += get_window().position
	_node_popup.popup()


func _popup_link_context_menu_at_mouse(connection: Dictionary) -> void:
	_node_creation_target = _graph_edit.get_local_mouse_position()
	_link_popup.clear()
	_link_popup.populate(connection)
	_link_popup.position = Vector2i(get_global_mouse_position())
	if not EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		_link_popup.position += get_window().position
	_link_popup.popup()
#endregion


#region Output Node
func _update_output_node() -> void:
	if is_instance_valid(_output_node):
		await _output_node.update_slots()
		await get_tree().process_frame
		_graph_edit.remove_invalid_connections()
#endregion


#region Connections
func update_connections() -> void:
	for node in _graph_edit.get_children():
		if node is GraphNode:
			node.connections.clear()

	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	for connection in connections:
		var to_node: GraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		to_node.connections.append(connection)


func _on_graph_edit_connection_to_empty(_from_node: StringName, _from_port: int, _release_position: Vector2) -> void:
	_popup_create_node_menu_at_mouse()
#endregion


#region Buttons
func _on_generate_button_pressed() -> void:
	_selected_generator.generate()


func _on_reload_node_tree_button_pressed() -> void:
	_create_node_tree.populate()

func _on_load_button_pressed() -> void:
	_file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	_selected_generator.data = load(path)


func _on_reload_parameters_list_button_pressed() -> void:
	if not is_instance_valid(_selected_generator) or not is_instance_valid(_selected_generator.data):
		return

	var existing_parameters: Array[String]
	for node in _graph_edit.get_children():
		if node is not GaeaGraphNode:
			continue

		if node.resource is GaeaNodeParameter:
			existing_parameters.append(node.get_arg_value("name"))


	for param in _selected_generator.data.get_parameter_list().keys():
		if param in existing_parameters:
			continue

		_selected_generator.data.remove_parameter(param)
	_selected_generator.notify_property_list_changed()


func _on_online_docs_button_pressed() -> void:
	OS.shell_open("https://gaea-docs.readthedocs.io/")


#region Popout Window
func _on_window_popout_button_pressed() -> void:
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
	_window_popout_button.hide()
	_window_popout_separator.hide()


func _get_multiwindow_support_tooltip_text() -> String:
	# Adapted from https://github.com/godotengine/godot/blob/a8598cd8e261716fa3addb6f10bb57c03a061be9/editor/editor_node.cpp#L4725-L4737
	if EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		return tr("Multi-window support is not available because Interface > Editor > Single Window Mode is enabled in the editor settings.")
	elif not EditorInterface.get_editor_settings().get_setting("interface/multi_window/enable"):
		return tr("Multi-window support is not available because Interface > Multi Window > Enable is disabled in the editor settings.")
	elif DisplayServer.has_feature(DisplayServer.FEATURE_SUBWINDOWS):
		return tr("Multi-window support is not available because the `--single-window` command line argument was used to start the editor.")
	else:
		return tr("Multi-window support is not available because the current platform doesn't support multiple windows.")


func _on_window_close_requested(original_parent: Control, window: Window) -> void:
	reparent(original_parent, false)
	window.queue_free()
	_window_popout_button.show()
	_window_popout_separator.show()
#endregion
#endregion


#region Other
func get_selected_generator() -> GaeaGenerator:
	return _selected_generator


func update_bottom_note():
	var mouse_position = _graph_edit.get_local_mouse_position()
	if get_rect().has_point(mouse_position):
		_bottom_note_label.visible = true
		_bottom_note_label.text = "%s" % [
			Vector2i(_graph_edit.local_to_grid(_graph_edit.get_local_mouse_position(), Vector2.ZERO, false))
		]
	else:
		_bottom_note_label.visible = false
#endregion


func _on_graph_edit_scroll_offset_changed(offset: Vector2) -> void:
	if is_loading:
		return
		
	if is_instance_valid(_selected_generator):
		if is_instance_valid(_selected_generator.data):
			_selected_generator.data.scroll_offset = offset
			_selected_generator.data.zoom = _graph_edit.zoom
