@tool
class_name GaeaGraphEdit
extends GraphEdit

@export var main_editor: GaeaMainEditor
@export var bottom_note_label: RichTextLabel

## List of nodes attached to a frame (element, frame)
var attached_elements: Dictionary[StringName, StringName]

## Currently edited resource
var graph: GaeaGraph :
	set(value):
		graph = value
		if not is_instance_valid(graph):
			hide()
		else:
			show()

## Buffer used to store copied nodes
var copy_buffer: GaeaNodesCopy

## Flag that indicate if the editor is currently loading a graph
var is_loading = false

## Reference to the output node
var _output_node: GaeaOutputGraphNode

## Reference to the window popout separator
var _window_popout_separator: VSeparator

## Reference to the window popout button
var _window_popout_button: Button

var _back_icon: Texture2D
var _forward_icon: Texture2D


func _init() -> void:
	for cast in GaeaValueCast.get_cast_list():
		add_valid_connection_type(cast[0], cast[1])


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	add_theme_color_override(&"connection_rim_color", Color("141414"))
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_editor_script_changed)
	_add_toolbar_buttons()


#region Saving and Loading
func populate(new_graph: GaeaGraph) -> void:
	graph = new_graph
	graph.ensure_initialized()
	if not graph.layer_count_modified.is_connected(_update_output_node):
		graph.layer_count_modified.connect(_update_output_node)
	_load_data()


func unpopulate() -> void:
	if is_instance_valid(graph) and graph.layer_count_modified.is_connected(_update_output_node):
		graph.layer_count_modified.disconnect(_update_output_node)
	_output_node = null

	for child in get_children():
		if child is GraphElement:
			child.queue_free()
	graph = null


func _load_data() -> void:
	is_loading = true
	var has_output_node: bool = false
	for id in graph.get_ids():
		var saved_data = graph.get_node_data(id)
		if saved_data.is_empty():
			continue
		var node := instantiate_node(id)

		if graph.get_node(id) is GaeaNodeOutput:
			if has_output_node:
				push_warning("Duplicate Output node found, deleting node id %d" % id)
				delete_nodes([node.name])
			else:
				has_output_node = true
				_output_node = node

	if not has_output_node:
		_output_node = _add_node(GaeaNodeOutput.new(), Vector2.ZERO)

	_output_node.add_to_group(&"cant_delete")
	_load_scroll_offset.call_deferred(
		_output_node.size * 0.5 - get_rect().size * 0.5
	)

	_update_output_node()
	# from_node and to_node are indexes in the resources array
	_load_connections.call_deferred(graph.get_all_connections())

	update_connections()
	set_deferred(&"is_loading", false)


func _load_scroll_offset(default_offset: Vector2) -> void:
	if is_nan(graph.scroll_offset.x):
		graph.scroll_offset = default_offset
	set_scroll_offset(graph.scroll_offset)
	set_zoom(graph.zoom)


func _load_connections(connections_list: Array[Dictionary]) -> void:
	for connection in connections_list:
		var from_node_resource := graph.get_node(connection.from_node)
		if not is_instance_valid(from_node_resource):
			continue
		var from_node := from_node_resource.node

		var to_node_resource := graph.get_node(connection.to_node)
		if not is_instance_valid(to_node_resource):
			continue
		var to_node := to_node_resource.node

		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			continue

		if to_node.get_input_port_count() <= connection.to_port:
			continue

		connection_request.emit(
			from_node.name, connection.from_port, to_node.name, connection.to_port
		)
#endregion

#region Toolbar
func _add_toolbar_buttons() -> void:
	var container := get_menu_hbox()
	var panel: PanelContainer = container.get_parent()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 10.0
	panel.offset_top = 10.0
	panel.offset_right = -12.0

	var toggle_left_panel_button = Button.new()
	toggle_left_panel_button.theme_type_variation = &"FlatButton"
	_back_icon = EditorInterface.get_base_control().get_theme_icon(
		&"Back", &"EditorIcons"
	)
	_forward_icon = EditorInterface.get_base_control().get_theme_icon(
		&"Forward", &"EditorIcons"
	)
	toggle_left_panel_button.icon = _back_icon
	toggle_left_panel_button.tooltip_text = "Toggle Files Panel"
	container.add_child(toggle_left_panel_button)
	container.move_child(toggle_left_panel_button, 0)
	toggle_left_panel_button.pressed.connect(
		_on_toggle_left_panel_button_pressed.bind(toggle_left_panel_button)
	)

	var add_node_button = Button.new()
	add_node_button.text = "Add Node"
	add_node_button.theme_type_variation = &"FlatButton"
	add_node_button.pressed.connect(_add_node_button_pressed)
	container.add_child(add_node_button)
	container.move_child(add_node_button, 1)

	container.add_spacer(false)

	var online_docs_button = Button.new()
	online_docs_button.text = "Online Docs"
	online_docs_button.theme_type_variation = &"FlatButton"
	online_docs_button.icon = EditorInterface.get_base_control().get_theme_icon(&"ExternalLink", &"EditorIcons")
	online_docs_button.pressed.connect(_on_online_docs_button_pressed)
	container.add_child(online_docs_button)

	var about_button = Button.new()
	about_button.text = "About"
	about_button.theme_type_variation = &"FlatButton"
	about_button.icon = EditorInterface.get_base_control().get_theme_icon(&"NodeInfo", &"EditorIcons")
	about_button.pressed.connect(main_editor.about_popup_request.emit)
	container.add_child(about_button)

	_window_popout_separator = VSeparator.new()
	container.add_child(_window_popout_separator)

	_window_popout_button = Button.new()
	_window_popout_button.theme_type_variation = &"FlatButton"
	_window_popout_button.icon = EditorInterface.get_base_control().get_theme_icon(&"MakeFloating", &"EditorIcons")
	_window_popout_button.pressed.connect(main_editor.panel_popout_request.emit)
	container.add_child(_window_popout_button)

	if not EditorInterface.is_multi_window_enabled():
		_window_popout_button.disabled = true
		_window_popout_button.tooltip_text = _get_multiwindow_support_tooltip_text()


func _get_multiwindow_support_tooltip_text() -> String:
	# Adapted from https://github.com/godotengine/godot/blob/a8598cd8e261716fa3addb6f10bb57c03a061be9/editor/editor_node.cpp#L4725-L4737
	var prefix: String = "Multi-window support is not available because"
	if EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		return tr(prefix + " Interface > Editor > Single Window Mode is enabled in the editor settings.")
	if not EditorInterface.get_editor_settings().get_setting("interface/multi_window/enable"):
		return tr(prefix + " Interface > Multi Window > Enable is disabled in the editor settings.")
	if DisplayServer.has_feature(DisplayServer.FEATURE_SUBWINDOWS):
		return tr(prefix + " the `--single-window` command line argument was used to start the editor.")
	return tr(prefix + " the current platform doesn't support multiple windows.")


func _add_node_button_pressed() -> void:
	main_editor.popup_create_node_request.emit()
	main_editor.node_creation_target = size * 0.40


func _on_toggle_left_panel_button_pressed(button: Button) -> void:
	main_editor.gaea_panel.file_list.visible = not main_editor.gaea_panel.file_list.visible
	button.icon = _back_icon if main_editor.gaea_panel.file_list.visible else _forward_icon



func _on_online_docs_button_pressed() -> void:
	OS.shell_open("https://gaea-docs.readthedocs.io/")
#endregion

#region Nodes managment
func instantiate_node(id: int) -> GraphElement:
	var saved_data := graph.get_node_data(id)
	if graph.get_node_type(id) == GaeaGraph.NodeType.FRAME:
		var new_frame: GaeaGraphFrame = GaeaGraphFrame.new()
		new_frame.graph_edit = self
		add_child(new_frame)
		new_frame.load_save_data(saved_data)
		new_frame.id = id
		_load_attached_elements.bind(saved_data.get(&"attached", []), new_frame.name).call_deferred()
		return new_frame

	var resource := graph.get_node(id)
	if not is_instance_valid(resource):
		push_warning("Invalid resource", resource)
		return null

	var node: GaeaGraphNode = resource.get_scene().instantiate()
	resource.load_save_data(saved_data)
	if resource.get_scene_script() != null:
		node.set_script(resource.get_scene_script())

	if node is GaeaGraphNode:
		node.graph_edit = self
		node.remove_invalid_connections_requested.connect(remove_invalid_connections)
		node.load_save_data.call_deferred(saved_data)

	node.resource = resource
	resource.id = id
	node.position_offset = graph.get_node_position(id)
	add_child(node)

	return node


func _add_node(resource: GaeaNodeResource, local_grid_position: Vector2) -> GraphNode:
	var id := graph.add_node(resource, local_grid_position)
	resource.id = id
	return instantiate_node(id)


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	delete_nodes(nodes)


func delete_nodes(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node: GraphElement = get_node_or_null(NodePath(node_name))
		if node is GaeaGraphNode:
			if node.is_in_group(&"cant_delete"):
				continue

			for connection in node.connections:
				disconnect_node(
					connection.from_node,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)
			node.removed.emit()
			graph.remove_node(node.resource.id)
		elif node is GaeaGraphFrame:
			if attached_elements.has(node.name):
				var frame = attached_elements.get(node.name)
				for attached in get_attached_nodes_of_frame(node.name):
					detach_element_from_frame(attached)
					attach_graph_element_to_frame(attached, frame)
					_on_element_attached_to_frame(attached, frame)
			else:
				for attached in get_attached_nodes_of_frame(node.name):
					detach_element_from_frame(attached)
			graph.remove_node(node.id)

		node.queue_free()
		await node.tree_exited

	update_connections()


func get_selected() -> Array[Node]:
	return get_children().filter(
		func(child: Node) -> bool: return child is GraphElement and child.selected
	)


func get_selected_names() -> Array[StringName]:
	var selected := get_selected()
	var array: Array[StringName]
	for node: Node in selected:
		array.append(node.name)
	return array


func _update_output_node() -> void:
	if is_instance_valid(_output_node):
		_output_node.update_slots()
		remove_invalid_connections.call_deferred()


func _on_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	var node := _add_node(resource.duplicate(), local_to_grid(main_editor.node_creation_target))

	if node is GaeaGraphNode and is_instance_valid(main_editor.created_node_connect_to):
		var to_port := 0
		var slot_name: StringName
		var type: GaeaValue.Type
		var new_node_port_amount: int
		if main_editor.dragged_from_left:
			slot_name = main_editor.created_node_connect_to.resource.connection_idx_to_argument(
				main_editor.created_node_connect_to_port
			)
			type = main_editor.created_node_connect_to.resource.get_argument_type(slot_name)
			new_node_port_amount = node.resource._get_output_ports_list().size()
		else:
			slot_name = main_editor.created_node_connect_to.resource.connection_idx_to_output(
				main_editor.created_node_connect_to_port
			)
			type = main_editor.created_node_connect_to.resource.get_output_port_type(slot_name)
			new_node_port_amount = node.resource.get_arguments_list().size()

		while to_port < new_node_port_amount:
			var other_slot_name: StringName
			var other_type: GaeaValue.Type
			if main_editor.dragged_from_left:
				other_slot_name = node.resource.connection_idx_to_output(to_port)
				other_type = node.resource.get_output_port_type(other_slot_name)
			else:
				other_slot_name = node.resource.connection_idx_to_argument(to_port)
				other_type = node.resource.get_argument_type(other_slot_name)

			if GaeaValue.is_valid_connection(
				other_type if main_editor.dragged_from_left else type,
				type if main_editor.dragged_from_left else other_type
			):
				break
			to_port += 1

		if to_port < node.resource.get_arguments_list().size():
			if main_editor.dragged_from_left:
				connection_request.emit(
					node.name,
					to_port,
					main_editor.created_node_connect_to.name,
					main_editor.created_node_connect_to_port
				)
			else:
				connection_request.emit(
					main_editor.created_node_connect_to.name,
					main_editor.created_node_connect_to_port,
					node.name,
					to_port
				)


func _on_special_node_selected_for_creation(id: StringName) -> void:
	match id:
		&"frame":
			_add_frame()


func _on_new_reroute_requested(connection: Dictionary) -> void:
	var resource: GaeaNodeReroute = GaeaNodeReroute.new()
	var from_node: GraphNode = get_node_or_null(NodePath(connection.from_node))
	if not is_instance_valid(from_node):
		return

	resource.type = from_node.get_output_port_type(connection.from_port) as GaeaValue.Type
	var reroute: GaeaGraphNode = _add_node(resource, Vector2.ZERO)

	var offset = -reroute.get_output_port_position(0)
	offset.y -= reroute.get_slot_custom_icon_right(0).get_size().y * 0.5
	reroute.set_position_offset(local_to_grid(main_editor.node_creation_target, offset))

	graph.set_node_position(reroute.resource.id, reroute.position_offset)

	disconnection_request.emit.call_deferred(
		connection.from_node,
		connection.from_port,
		connection.to_node,
		connection.to_port,
	)
	connection_request.emit.call_deferred(
		connection.from_node,
		connection.from_port,
		reroute.name,
		0,
	)
	connection_request.emit.call_deferred(
		reroute.name,
		0,
		connection.to_node,
		connection.to_port,
	)
#endregion

#region Wiring
func update_connections() -> void:
	for node in get_children():
		if node is GaeaGraphNode:
			node.connections.clear()

	for connection in get_connection_list():
		var to_node: GraphNode = get_node_or_null(NodePath(connection.to_node))
		if is_instance_valid(to_node):
			to_node.connections.append(connection)


func _on_connection_from_empty(to_node: StringName, to_port: int, _release_position: Vector2) -> void:
	var node: GaeaGraphNode = get_node_or_null(NodePath(to_node))
	if not is_instance_valid(node):
		return

	var type: GaeaValue.Type = node.resource.get_argument_type(
		node.resource.connection_idx_to_argument(to_port)
	)
	main_editor.created_node_connect_to_port = to_port
	main_editor.dragged_from_left = true
	main_editor.popup_create_node_and_connect_node_request.emit(node, type)


func _on_connection_to_empty(from_node: StringName, from_port: int, _release_position: Vector2) -> void:
	var node: GaeaGraphNode = get_node_or_null(NodePath(from_node))
	if not is_instance_valid(node):
		return

	var type: GaeaValue.Type = node.resource.get_output_port_type(
		node.resource.connection_idx_to_output(from_port)
	)
	main_editor.created_node_connect_to_port = from_port
	main_editor.dragged_from_left = false
	main_editor.popup_create_node_and_connect_node_request.emit(node, type)


func _on_connection_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int
) -> void:
	if is_nodes_connected_relatively(from_node, to_node):
		return

	var to_graph_node: GaeaGraphNode = get_node_or_null(NodePath(to_node))
	if not is_instance_valid(to_graph_node):
		return

	var from_graph_node: GaeaGraphNode = get_node_or_null(NodePath(from_node))
	if not is_instance_valid(from_graph_node):
		return


	if to_graph_node is GaeaGraphNode:
		for connection in to_graph_node.connections:
			if connection.to_port == to_port:
				disconnection_request.emit(
					connection.from_node,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)
	else:
		for connection: Dictionary in get_connection_list():
			if connection.to_node == to_node and connection.to_port == to_port:
				disconnection_request.emit(
					connection.from_node,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)

	var error := graph.connect_nodes(
		from_graph_node.resource.id,
		from_port,
		to_graph_node.resource.id,
		to_port
	)

	# The already exists error is valid in this case since this function
	# also handles connection loading.
	if error != OK and error != ERR_ALREADY_EXISTS:
		return
	connect_node(from_node, from_port, to_node, to_port)

	update_connections()

	if from_graph_node.has_finished_loading():
		from_graph_node.notify_connections_updated.call_deferred()

	if to_graph_node.has_finished_loading():
		to_graph_node.notify_connections_updated.call_deferred()


func _on_disconnection_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int
) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	update_connections()

	var to_graph_node: GaeaGraphNode = get_node_or_null(NodePath(to_node))
	if not is_instance_valid(to_graph_node):
		return

	var from_graph_node: GaeaGraphNode = get_node_or_null(NodePath(from_node))
	if not is_instance_valid(from_graph_node):
		return

	graph.disconnect_nodes(
		from_graph_node.resource.id, from_port, to_graph_node.resource.id, to_port
	)

	if from_graph_node.has_finished_loading():
		from_graph_node.notify_connections_updated.call_deferred()
	if to_graph_node.has_finished_loading():
		to_graph_node.notify_connections_updated.call_deferred()


func remove_invalid_connections() -> void:
	for connection in get_connection_list():
		var to_node: GaeaGraphNode = get_node_or_null(NodePath(connection.to_node))
		var from_node: GaeaGraphNode = get_node_or_null(NodePath(connection.from_node))

		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			disconnect_node(
				connection.from_node, connection.from_port, connection.to_node, connection.to_port
			)
			continue

		if to_node.get_input_port_count() <= connection.to_port:
			disconnect_node(
				connection.from_node, connection.from_port, connection.to_node, connection.to_port
			)
			continue

		if from_node.get_output_port_count() <= connection.from_port:
			disconnect_node(
				connection.from_node, connection.from_port, connection.to_node, connection.to_port
			)
			continue

		var from_type: GaeaValue.Type = (
			from_node.get_output_port_type(connection.from_port) as GaeaValue.Type
		)
		var to_type: GaeaValue.Type = (
			to_node.get_input_port_type(connection.to_port) as GaeaValue.Type
		)
		if not is_valid_connection_type(from_type, to_type) and from_type != to_type:
			disconnect_node(
				connection.from_node, connection.from_port, connection.to_node, connection.to_port
			)
			to_node.notify_connections_updated.call_deferred()
			from_node.notify_connections_updated.call_deferred()
			continue


func is_nodes_connected_relatively(from_node: StringName, to_node: StringName) -> bool:
	var nodes_to_check: Array[StringName] = [from_node]
	while nodes_to_check.size() > 0:
		var node_name = nodes_to_check.pop_front()
		var node: GaeaGraphNode = get_node_or_null(NodePath(node_name))
		if not is_instance_valid(node) or node is not GaeaGraphNode:
			return false

		for connection in node.connections:
			nodes_to_check.append(connection.from_node)
			if connection.from_node == to_node:
				return true
	return false


func _is_node_hover_valid(
	from_node: StringName, _from_port: int, to_node: StringName, _to_port: int
) -> bool:
	if from_node == to_node:
		return false
	return true
#endregion

#region Frames
func _add_frame() -> void:
	var id: int = graph.add_frame(local_to_grid(main_editor.node_creation_target))
	instantiate_node(id)


func load_all_attached_elements() -> void:
	for frame in get_children().filter(
		func(node) -> bool: return node is GaeaGraphFrame
	):
		_load_attached_elements(graph.get_nodes_attached_to_frame(frame.id), frame.name)


func _load_attached_elements(attached: Array, frame_name: StringName) -> void:
	for id: int in attached:
		var node_resource: GaeaNodeResource = graph.get_node(id)
		var node: GraphElement
		if not is_instance_valid(node_resource):
			var graph_children := get_children()
			var attached_frame_idx := graph_children.find_custom(
				func(child: Node) -> bool: return child is GaeaGraphFrame and child.id == id
			)
			if attached_frame_idx != -1:
				node = graph_children[attached_frame_idx]
		else:
			node = node_resource.node

		if not is_instance_valid(node):
			continue

		attach_graph_element_to_frame(node.name, frame_name)
		_on_element_attached_to_frame(node.name, frame_name)


func _on_graph_elements_linked_to_frame_request(elements: Array, frame: StringName) -> void:
	for element in elements:
		attach_graph_element_to_frame(element, frame)
		_on_element_attached_to_frame(element, frame)


func detach_element_from_frame(element: StringName) -> void:
	detach_graph_element_from_frame(element)
	var node: GraphElement = get_node_or_null(NodePath(element))
	if node is GaeaGraphNode:
		graph.detach_node_from_frame(node.resource.id)
	elif node is GaeaGraphFrame:
		graph.detach_node_from_frame(node.id)
	attached_elements.erase(element)


func _on_element_attached_to_frame(element: StringName, frame: StringName) -> void:
	attached_elements.set(element, frame)
	var node: GraphElement = get_node_or_null(NodePath(element))
	if not is_instance_valid(node):
		return

	var frame_node: GaeaGraphFrame = get_node_or_null(NodePath(frame))
	if not is_instance_valid(frame_node):
		return

	if node is GaeaGraphNode:
		graph.attach_node_to_frame(node.resource.id, frame_node.id)
	elif node is GaeaGraphFrame:
		graph.attach_node_to_frame(node.id, frame_node.id)
#endregion

#region Copy/Paste
func _copy_nodes(data: GaeaNodesCopy) -> void:
	copy_buffer = data


func _paste_nodes(at_position: Vector2, data: GaeaNodesCopy = copy_buffer) -> void:
	for node in get_selected():
		node.selected = false

	var copy_ids := graph.paste_nodes(data, at_position)
	var new_connections: Array[Dictionary]
	for id in copy_ids:
		instantiate_node(id).selected = true
		new_connections.append_array(graph.get_node_connections(id))

	_load_connections.call_deferred(new_connections)


func _get_copy_data(nodes: Array) -> GaeaNodesCopy:
	var copy_data: GaeaNodesCopy = GaeaNodesCopy.new()
	for selected in nodes:
		if selected is GaeaGraphNode:
			if selected.resource is GaeaNodeOutput:
				continue

			copy_data.add_node(
				selected.resource.id,
				selected.resource.duplicate_deep(),
				selected.position_offset,
				graph.get_node_data(selected.resource.id).duplicate_deep()
			)
			copy_data.add_connections(graph.get_node_connections(selected.resource.id).duplicate())
		elif selected is GaeaGraphFrame:
			copy_data.add_frame(
				selected.id,
				selected.position_offset,
				graph.get_node_data(selected.id).duplicate_deep()
			)
	return copy_data


func _on_duplicate_nodes_request() -> void:
	var copy_data := _get_copy_data(get_selected())
	_copy_nodes(copy_data)
	_paste_nodes(copy_data.get_origin() + Vector2(snapping_distance, snapping_distance))


func _on_copy_nodes_request() -> void:
	_copy_nodes(_get_copy_data(get_selected()))


func _on_paste_nodes_request() -> void:
	_paste_nodes(local_to_grid(get_local_mouse_position()))


func _on_cut_nodes_request() -> void:
	_copy_nodes(_get_copy_data(get_selected()))
	delete_nodes(get_selected_names())
#endregion


#region Inputs and watchers
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position = get_local_mouse_position()
		if get_rect().has_point(mouse_position):
			bottom_note_label.visible = true
			bottom_note_label.text = "%s" % Vector2i(local_to_grid(mouse_position, Vector2.ZERO, false))
		else:
			bottom_note_label.visible = false


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			# Check if we clicked on a connection
			var mouse_position = get_local_mouse_position()
			var connection = get_closest_connection_at_point(mouse_position, 10.0)
			if not connection.is_empty():
				main_editor.popup_link_context_menu_at_mouse_request.emit(connection)
				return

			var selected: Array = get_selected()
			if selected.is_empty() and not is_instance_valid(main_editor.graph_edit.copy_buffer):
				main_editor.popup_create_node_request.emit()
			else:
				main_editor.popup_node_context_menu_at_mouse_request.emit(selected)


func _on_scroll_offset_changed(offset: Vector2) -> void:
	if is_loading:
		return
	if is_instance_valid(graph):
		graph.scroll_offset = offset
		graph.zoom = zoom


func _on_editor_script_changed(script: Script):
	var editor := EditorInterface.get_script_editor().get_current_editor()
	if not editor.edited_script_changed.is_connected(_on_edited_script_changed):
		editor.edited_script_changed.connect(_on_edited_script_changed.bind(script))


func _on_edited_script_changed(script: Script):
	if not is_instance_valid(script) or not script.can_instantiate():
		return

	for child in get_children():
		if child is GaeaGraphNode:
			if script == child.resource.get_script():
				child._rebuild.call_deferred()
#endregion

#region Utils and misc
@warning_ignore("shadowed_variable_base_class")
func set_window_popout_button_visible(visible: bool) -> void:
	_window_popout_button.visible = visible
	_window_popout_separator.visible = visible


## This function converts a local position to a grid position based on the current zoom level and scroll offset.
## It also applies snapping if enabled in the GraphEdit.
func local_to_grid(
	local_position: Vector2, grid_offset: Vector2 = Vector2.ZERO, enable_snapping: bool = true
) -> Vector2:
	local_position = (local_position + scroll_offset) / zoom
	local_position += grid_offset
	if enable_snapping and snapping_enabled:
		return local_position.snapped(Vector2.ONE * snapping_distance)
	return local_position


func _on_main_editor_visibility_changed() -> void:
	set_connection_lines_curvature(GaeaEditorSettings.get_line_curvature())
	set_grid_pattern(GaeaEditorSettings.get_grid_pattern())
	set_connection_lines_thickness(GaeaEditorSettings.get_line_thickness())
	set_minimap_opacity(GaeaEditorSettings.get_minimap_opacity())
#endregion
