@tool
extends GraphEdit


signal connection_update_requested

var attached_elements: Dictionary
var generator: GaeaGenerator

func _init() -> void:
	for cast in GaeaValueCast.get_cast_list():
		add_valid_connection_type(cast[0], cast[1])


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	add_theme_color_override(&"connection_rim_color", Color("141414"))
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_editor_script_changed)


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	delete_nodes(nodes)


func delete_nodes(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node: GraphElement = get_node(NodePath(node_name))
		if node is GaeaGraphNode:
			if node.resource is GaeaNodeOutput:
				continue

			for connection in node.connections:
				disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)

			node.removed.emit()
			generator.data.remove_node(node.resource.id)
		elif node is GaeaGraphFrame:
			for attached in get_attached_nodes_of_frame(node.name):
				attached_elements.erase(attached)
			generator.data.remove_node(node.id)
		node.queue_free()
		await node.tree_exited

	connection_update_requested.emit()


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if is_nodes_connected_relatively(from_node, to_node):
		return

	var to_graph_node: GaeaGraphNode = get_node(NodePath(to_node))
	var from_graph_node: GaeaGraphNode = get_node(NodePath(from_node))

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

	var error := generator.data.connect_nodes(
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

	connection_update_requested.emit()

	if from_graph_node.has_finished_loading():
		from_graph_node.notify_connections_updated.call_deferred()

	if to_graph_node.has_finished_loading():
		to_graph_node.notify_connections_updated.call_deferred()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	connection_update_requested.emit()

	var to_graph_node: GaeaGraphNode = get_node(NodePath(to_node))
	var from_graph_node: GaeaGraphNode = get_node(NodePath(from_node))

	generator.data.disconnect_nodes(from_graph_node.resource.id, from_port, to_graph_node.resource.id, to_port)

	if from_graph_node.has_finished_loading():
		from_graph_node.notify_connections_updated.call_deferred()
	if to_graph_node.has_finished_loading():
		to_graph_node.notify_connections_updated.call_deferred()


func remove_invalid_connections() -> void:
	for connection in get_connection_list():
		var to_node: GaeaGraphNode = get_node(NodePath(connection.to_node))
		var from_node: GaeaGraphNode = get_node(NodePath(connection.from_node))


		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if to_node.get_input_port_count() <= connection.to_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if from_node.get_output_port_count() <= connection.from_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		var from_type: GaeaValue.Type = from_node.get_output_port_type(connection.from_port) as GaeaValue.Type
		var to_type: GaeaValue.Type = to_node.get_input_port_type(connection.to_port) as GaeaValue.Type
		if not is_valid_connection_type(from_type, to_type) and from_type != to_type:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			to_node.notify_connections_updated.call_deferred()
			from_node.notify_connections_updated.call_deferred()
			continue


func is_nodes_connected_relatively(from_node: StringName, to_node: StringName) -> bool:
	var nodes_to_check: Array[StringName] = [from_node]
	while nodes_to_check.size() > 0:
		var node_name = nodes_to_check.pop_front()
		var node: GaeaGraphNode = get_node(NodePath(node_name))
		if node is GaeaGraphNode:
			for connection in node.connections:
				nodes_to_check.append(connection.from_node)
				if connection.from_node == to_node:
					return true
	return false

func get_selected() -> Array:
	return get_children().filter(func(child: Node) -> bool:
		return child is GraphElement and child.selected
	)


func get_selected_names() -> Array[StringName]:
	var selected := get_selected()
	var array: Array[StringName]
	for node: Node in selected:
		array.append(node.name)
	return array


func _on_graph_elements_linked_to_frame_request(elements: Array, frame: StringName) -> void:
	for element in elements:
		attach_graph_element_to_frame(element, frame)
		_on_element_attached_to_frame(element, frame)


func detach_element_from_frame(element: StringName) -> void:
	detach_graph_element_from_frame(element)
	var node: GraphElement = get_node(NodePath(element))
	if node is GaeaGraphNode:
		generator.data.detach_node_from_frame(node.resource.id)
	elif node is GaeaGraphFrame:
		generator.data.detach_node_from_frame(node.id)
	attached_elements.erase(element)


func _on_element_attached_to_frame(element: StringName, frame: StringName) -> void:
	attached_elements.set(element, frame)
	var node: GraphElement = get_node(NodePath(element))
	var frame_node: GaeaGraphFrame = get_node(NodePath(frame))

	if node is GaeaGraphNode:
		generator.data.attach_node_to_frame(node.resource.id, frame_node.id)
	elif node is GaeaGraphFrame:
		generator.data.attach_node_to_frame(node.id, frame_node.id)


func _is_node_hover_valid(from_node: StringName, _from_port: int, to_node: StringName, _to_port: int) -> bool:
	if from_node == to_node:
		return false
	return true


## This function converts a local position to a grid position based on the current zoom level and scroll offset.
## It also applies snapping if enabled in the GraphEdit.
func local_to_grid(local_position: Vector2, grid_offset: Vector2 = Vector2.ZERO, enable_snapping: bool = true) -> Vector2:
	local_position = (local_position + scroll_offset) / zoom
	local_position += grid_offset
	if enable_snapping and snapping_enabled:
		return local_position.snapped(Vector2.ONE * snapping_distance)
	else:
		return local_position


func _on_editor_script_changed(script: Script):
	var editor := EditorInterface.get_script_editor().get_current_editor()
	if not editor.edited_script_changed.is_connected(_on_edited_script_changed):
		editor.edited_script_changed.connect(_on_edited_script_changed.bind(script))


func _on_edited_script_changed(script: Script):
	if not script.can_instantiate():
		return

	for child in get_children():
		if child is GaeaGraphNode:
			if script == child.resource.get_script():
				child._rebuild.call_deferred()
