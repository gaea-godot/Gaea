@tool
extends Control

var _selected_generator: GaeaGenerator = null: get = get_selected_generator
var _output_node: GraphNode

## Local position on [GraphEdit] for a node that may be created in the future.
var _node_creation_target: Vector2 = Vector2.ZERO

const _LinkPopup = preload("uid://btt4eqjkp5pyf")
const _RerouteNode = preload("uid://bs40iof8ipbkq")

@onready var _no_data: Control = $NoData
@onready var _editor: Control = $Editor
@onready var _graph_edit: GraphEdit = %GraphEdit
@onready var _create_node_popup: Window = %CreateNodePopup
@onready var _create_node_panel: Panel = %CreateNodePanel
@onready var _node_popup: PopupMenu = %NodePopup
@onready var _link_popup: _LinkPopup = %LinkPopup
@onready var _create_node_tree: Tree = %Tree
@onready var _search_bar: LineEdit = %SearchBar
@onready var _save_button: Button = $Editor/VBoxContainer/HBoxContainer/SaveButton
@onready var _load_button: Button = $Editor/VBoxContainer/HBoxContainer/LoadButton
@onready var _reload_node_tree_button: Button = $Editor/VBoxContainer/HBoxContainer/ReloadNodeTreeButton
@onready var _reload_parameters_list_button: Button = $Editor/VBoxContainer/HBoxContainer/ReloadParametersListButton
@onready var _file_dialog: FileDialog = $FileDialog
@onready var _window_popout_button: Button = $Editor/VBoxContainer/HBoxContainer/WindowPopoutButton
@onready var _window_popout_separator: VSeparator = $Editor/VBoxContainer/HBoxContainer/WindowPopoutSeparator
@onready var _bottom_note_label: RichTextLabel = %BottomNote



func _ready() -> void:
	_reload_node_tree_button.icon = preload("../assets/reload_tree.svg")
	_reload_parameters_list_button.icon = preload("../assets/reload_variables_list.svg")
	_save_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Save", &"EditorIcons")
	_load_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Load", &"EditorIcons")
	_window_popout_button.icon = EditorInterface.get_base_control().get_theme_icon(&"MakeFloating", &"EditorIcons")
	_create_node_panel.add_theme_stylebox_override(&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"panel", &"PopupPanel"))


func populate(node: GaeaGenerator) -> void:
	_remove_children()
	_output_node = null
	if is_instance_valid(_selected_generator) and _selected_generator.data_changed.is_connected(_on_data_changed):
		_selected_generator.data_changed.disconnect(_on_data_changed)
	_selected_generator = node
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
	_save_data()

	if is_instance_valid(_selected_generator):
		if is_instance_valid(_selected_generator.data) and _selected_generator.data.layer_count_modified.is_connected(_update_output_node):
			_selected_generator.data.layer_count_modified.disconnect(_update_output_node)
		if _selected_generator.data_changed.is_connected(_on_data_changed):
			_selected_generator.data_changed.disconnect(_on_data_changed)

	_selected_generator = null

	_remove_children()


func _remove_children() -> void:
	for child in _graph_edit.get_children():
		if child is GraphElement:
			child.queue_free()


func _on_new_data_button_pressed() -> void:
	_selected_generator.data = GaeaData.new()


func _on_data_changed() -> void:
	_remove_children()
	populate(_selected_generator)


func _popup_create_node_menu_at_mouse() -> void:
	_create_node_popup.position = get_global_mouse_position() as Vector2i + get_window().position
	_node_creation_target = _graph_edit.get_local_mouse_position()
	_create_node_popup.popup()
	_search_bar.grab_focus()


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

func _add_node(resource: GaeaNodeResource) -> GraphNode:
	@warning_ignore("static_called_on_instance")
	var node: GaeaGraphNode = resource.get_scene().instantiate()
	node.resource = resource
	node.generator = get_selected_generator()
	_graph_edit.add_child(node)

	#node.set_generator_reference(_selected_generator)
	node.on_added()
	node.save_requested.connect(_save_data)
	node.name = node.name.replace("@", "_")
	return node


func _popup_node_context_menu_at_mouse(selected_nodes: Array) -> void:
	_node_popup.clear()
	_node_popup.populate(selected_nodes)

	_node_popup.position = get_global_mouse_position() as Vector2i + get_window().position
	_node_popup.popup()


func _popup_link_context_menu_at_mouse(connexion: Dictionary) -> void:
	_link_popup.clear()
	_link_popup.populate(connexion)

	_link_popup.position = get_global_mouse_position() as Vector2i + get_window().position
	_node_creation_target = _graph_edit.get_local_mouse_position()
	_link_popup.popup()


func _add_node_at_position(resource: GaeaNodeResource, local_grid_position: Vector2) -> GraphNode:
	var node := _add_node(resource)
	node.set_position_offset(_local_to_grid(local_grid_position))
	_save_data.call_deferred()
	return node


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_create_node_popup.hide()
	_add_node_at_position(resource, _node_creation_target)


func _on_cancel_create_button_pressed() -> void:
	_create_node_popup.hide()


func _on_generate_button_pressed() -> void:
	_save_data()

	_selected_generator.generate()


func _update_output_node() -> void:
	if is_instance_valid(_output_node):
		await _output_node.update_slots()
		await get_tree().process_frame
		_graph_edit.remove_invalid_connections()


func get_selected_generator() -> GaeaGenerator:
	return _selected_generator


func update_connections() -> void:
	for node in _graph_edit.get_children():
		if node is GraphNode:
			node.connections.clear()

	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	for connection in connections:
		var to_node: GraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		to_node.connections.append(connection)


func _save_data() -> void:
	if not is_instance_valid(_selected_generator) or not is_instance_valid(_selected_generator.data):
		return

	_selected_generator.data.node_data.clear()
	_selected_generator.data.resources.clear()
	_selected_generator.data.connections.clear()
	_selected_generator.data.other.clear()

	var resources: Array[GaeaNodeResource]
	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	var node_data: Array[Dictionary]
	var other: Dictionary

	for child in _graph_edit.get_children():
		if child is GraphNode:
			resources.append(child.resource)
		elif child is GraphFrame:
			other.get_or_add("frames", []).append({
				"title": child.title,
				"tint_color": child.tint_color,
				"tint_color_enabled": child.tint_color_enabled,
				"position": child.position_offset,
				"attached": _graph_edit.get_attached_nodes_of_frame(child.name),
				"size": child.size,
				"autoshrink": child.autoshrink_enabled,
				"name": child.name
			})

	for connection in connections:
		var from_node: GraphNode = _graph_edit.get_node(NodePath(connection.from_node))
		var to_node: GraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		connection.from_node = resources.find(from_node.resource)
		connection.to_node = resources.find(to_node.resource)

	for resource in resources:
		node_data.append(resource.node.get_save_data())

	other["scroll_offset"] = _graph_edit.scroll_offset
	_selected_generator.data.connections = connections
	_selected_generator.data.resources = resources
	_selected_generator.data.node_data = node_data
	_selected_generator.data.other = other


func _load_data() -> void:
	_graph_edit.scroll_offset = _selected_generator.data.other.get("scroll_offset", Vector2.ZERO)

	var has_output_node: bool = false
	for idx in _selected_generator.data.resources.size():
		var resource: GaeaNodeResource = _selected_generator.data.resources[idx]
		var node: GraphNode = _add_node(resource)
		var node_data: Dictionary = _selected_generator.data.node_data[idx]

		if node_data.has("name"):
			node.name = node_data.get("name")

		if resource.is_output:
			has_output_node = true
			_output_node = node

		if is_instance_valid(node):
			node.load_save_data.call_deferred(node_data)

	if not has_output_node:
		var node: GraphNode = _add_node(preload("res://addons/gaea/graph/nodes/output_node_resource.tres"))
		_graph_edit.set_zoom(1.0)
		_graph_edit.set_scroll_offset(node.size * 0.5 - _graph_edit.get_rect().size * 0.5)

	# from_node and to_node are indexes in the resources array
	for connection in _selected_generator.data.connections:
		var from_node: GraphNode = _selected_generator.data.resources[connection.from_node].node
		var to_node: GraphNode = _selected_generator.data.resources[connection.to_node].node

		if to_node.get_input_port_count() <= connection.to_port:
			continue
		_graph_edit.connection_request.emit(from_node.name, connection.from_port, to_node.name, connection.to_port)

	update_connections()

	for frame: Dictionary in _selected_generator.data.other.get("frames", []):
		var new_frame: GraphFrame = GraphFrame.new()
		new_frame.title = frame.get("title", "Frame")
		new_frame.position_offset = frame.get("position", Vector2.ZERO)
		new_frame.size = frame.get("size", Vector2(64, 64))
		new_frame.tint_color = frame.get("tint_color", new_frame.tint_color)
		new_frame.tint_color_enabled = frame.get("tint_color_enabled", false)
		new_frame.name = frame.get_or_add("name", new_frame.name)
		new_frame.autoshrink_enabled = frame.get("autoshrink", true)
		_graph_edit.add_child(new_frame)

	for frame: Dictionary in _selected_generator.data.other.get("frames", []):
		for attached: StringName in frame.get("attached", []):
			_graph_edit.attach_graph_element_to_frame(attached, frame.get("name"))
			_graph_edit._on_element_attached_to_frame(attached, frame.get("name"))


func _on_graph_edit_connection_to_empty(_from_node: StringName, _from_port: int, _release_position: Vector2) -> void:
	_popup_create_node_menu_at_mouse()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_save_data()


func _on_node_popup_id_pressed(id: int) -> void:
	match id:
		0:
			_popup_create_node_menu_at_mouse()
		2:
			_graph_edit.delete_nodes_request.emit(_graph_edit.get_selected_names())


func _on_tree_special_node_selected_for_creation(id: StringName) -> void:
	match id:
		&"frame":
			var new_frame: GraphFrame = GraphFrame.new()
			new_frame.size = Vector2(512, 256)
			new_frame.set_position_offset((_graph_edit.get_local_mouse_position() + _graph_edit.scroll_offset) / _graph_edit.zoom)
			new_frame.title = "Frame"
			_graph_edit.add_child(new_frame)
			new_frame.name = new_frame.name.replace("@", "_")
			_save_data.call_deferred()
	_create_node_popup.hide()


func _on_reload_node_tree_button_pressed() -> void:
	_create_node_tree.populate()


func _on_save_button_pressed() -> void:
	_save_data()


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

		if node.resource is GaeaVariableNodeResource:
			existing_parameters.append(node.get_arg_value("name"))


	for param in _selected_generator.data.parameters:
		if param in existing_parameters:
			continue

		_selected_generator.data.parameters.erase(param)
	_selected_generator.notify_property_list_changed()


func _on_window_popout_button_pressed() -> void:
	var window: Window = Window.new()
	window.min_size = get_combined_minimum_size()
	window.size = size
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


func _on_window_close_requested(original_parent: Control, window: Window) -> void:
	reparent(original_parent, false)
	window.queue_free()
	_window_popout_button.show()
	_window_popout_separator.show()


func _on_new_reroute_requested(connection: Dictionary) -> void:
	var reroute: _RerouteNode = _add_node(_RerouteNode.create_resource())

	var offset = - reroute.get_output_port_position(0)
	offset.y -= reroute.get_slot_custom_icon_right(0).get_size().y * 0.5
	reroute.set_position_offset(_local_to_grid(_node_creation_target, offset))

	var from_node: GraphNode = _graph_edit.get_node(NodePath(connection.from_node))
	var link_type := from_node.get_output_port_type(connection.from_port) as GaeaGraphNode.SlotTypes
	reroute.type = link_type

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


func update_bottom_note():
	var mouse_position = _graph_edit.get_local_mouse_position()
	if get_rect().has_point(mouse_position):
		_bottom_note_label.visible = true
		_bottom_note_label.text = "%s" % [
			Vector2i(_local_to_grid(_graph_edit.get_local_mouse_position(), Vector2.ZERO, false))
		]
	else:
		_bottom_note_label.visible = false


## This function converts a local position to a grid position based on the current zoom level and scroll offset.
## It also applies snapping if enabled in the GraphEdit.
## @param local_position The local position to convert.
## @param grid_offset An optional offset to apply to the grid position.
## @return The converted grid position.
func _local_to_grid(local_position: Vector2, grid_offset: Vector2 = Vector2.ZERO, enable_snapping: bool = true) -> Vector2:
	local_position = (local_position + _graph_edit.scroll_offset) / _graph_edit.zoom
	local_position += grid_offset
	if enable_snapping and _graph_edit.snapping_enabled:
		return local_position.snapped(Vector2.ONE * _graph_edit.snapping_distance)
	else:
		return local_position


func _on_create_node_popup_close_requested() -> void:
	_create_node_popup.hide()
