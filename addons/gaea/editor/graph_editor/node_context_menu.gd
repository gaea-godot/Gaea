@tool
class_name GaeaPopupNodeContextMenu
extends PopupMenu

enum Action {
	ADD,
	CUT,
	COPY,
	PASTE,
	DUPLICATE,
	DELETE,
	CLEAR_BUFFER,
	RENAME,
	ENABLE_TINT,
	TINT,
	GROUP_IN_FRAME,
	DETACH,
	ENABLE_AUTO_SHRINK,
	OPEN_IN_INSPECTOR
}

@export var main_editor: GaeaMainEditor
@export var graph_edit: GaeaGraphEdit


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	hide()
	id_pressed.connect(_on_id_pressed)


func populate(selected: Array) -> void:
	add_item("Add Node", Action.ADD)
	add_separator()
	add_item("Copy", Action.COPY)
	add_item("Paste", Action.PASTE)
	add_item("Duplicate", Action.DUPLICATE)
	add_item("Cut", Action.CUT)
	add_item("Delete", Action.DELETE)
	add_item("Clear Copy Buffer", Action.CLEAR_BUFFER)

	if not is_instance_valid(graph_edit.copy_buffer):
		set_item_disabled(get_item_index(Action.PASTE), true)
		set_item_disabled(get_item_index(Action.CLEAR_BUFFER), true)
	if not selected.is_empty():
		add_separator()
		add_item("Group in New Frame", Action.GROUP_IN_FRAME)

	for node: GraphElement in selected:
		if graph_edit.attached_elements.has(node.name):
			add_item("Detach from Parent Frame", Action.DETACH)
			break

	if selected.is_empty():
		set_item_disabled(get_item_index(Action.DUPLICATE), true)
		set_item_disabled(get_item_index(Action.COPY), true)
		set_item_disabled(get_item_index(Action.CUT), true)
		set_item_disabled(get_item_index(Action.DELETE), true)
		return

	if selected.front() is GaeaGraphFrame and selected.size() == 1:
		add_separator()
		add_item("Rename Frame", Action.RENAME)
		add_check_item("Enable Auto Shrink", Action.ENABLE_AUTO_SHRINK)
		add_check_item("Enable Tint Color", Action.ENABLE_TINT)
		add_item("Set Tint Color", Action.TINT)
		set_item_disabled(get_item_index(Action.TINT), not selected.front().tint_color_enabled)

		set_item_checked(get_item_index(Action.ENABLE_TINT), selected.front().tint_color_enabled)
		set_item_checked(
			get_item_index(Action.ENABLE_AUTO_SHRINK), selected.front().autoshrink_enabled
		)
		size = get_contents_minimum_size()

	if selected.front() is GaeaGraphNode and selected.size() == 1:
		var node: GaeaGraphNode = selected.front()
		var resource: GaeaNodeResource = node.resource
		if resource is GaeaNodeParameter:
			var parameter: Dictionary = graph_edit.graph.get_parameter_dictionary(node.get_arg_value("name"))
			if parameter.get("value") is Resource:
				add_separator()
				add_item("Open In Inspector", Action.OPEN_IN_INSPECTOR)


func _on_id_pressed(id: int) -> void:
	var idx: int = get_item_index(id)
	match id:
		Action.ADD:
			main_editor.popup_create_node_request.emit()
		Action.COPY:
			graph_edit.copy_nodes_request.emit()
		Action.PASTE:
			graph_edit.paste_nodes_request.emit()
		Action.DUPLICATE:
			graph_edit.duplicate_nodes_request.emit()
		Action.CUT:
			graph_edit.cut_nodes_request.emit()
		Action.DELETE:
			graph_edit.delete_nodes_request.emit(graph_edit.get_selected_names())
		Action.CLEAR_BUFFER:
			graph_edit.copy_buffer = null

		Action.RENAME:
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GaeaGraphFrame:
				node.start_rename(owner)

		Action.TINT:
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GaeaGraphFrame:
				node.start_tint_color_change(owner)
		Action.ENABLE_TINT:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GaeaGraphFrame:
				node.set_tint_color_enabled(is_item_checked(idx))
				graph_edit.graph.set_node_data_value(node.id, &"tint_color_enabled", is_item_checked(idx))
		Action.ENABLE_AUTO_SHRINK:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GaeaGraphFrame:
				node.set_autoshrink_enabled(is_item_checked(idx))
		Action.GROUP_IN_FRAME:
			var selected: Array[StringName] = graph_edit.get_selected_names()
			_group_nodes_in_frame(selected)

		Action.DETACH:
			var selected: Array = graph_edit.get_selected()
			for node: GraphElement in selected:
				if graph_edit.attached_elements.has(node.name):
					graph_edit.detach_element_from_frame(node.name)
		Action.OPEN_IN_INSPECTOR:
			var node: GaeaGraphNode = graph_edit.get_selected().front()
			var resource: GaeaNodeResource = node.resource
			if resource is GaeaNodeParameter:
				var parameter: Dictionary = graph_edit.graph.get_parameter_dictionary(node.get_arg_value("name"))
				var value: Variant = parameter.get("value")
				if value is Resource and is_instance_valid(value):
					EditorInterface.edit_resource(value)


func _get_node_frame_parents_list(node_name: StringName) -> Array[StringName]:
	var list: Array[StringName] = []
	var loop_limit: int = 50
	while loop_limit > 0:
		loop_limit -= 1
		if graph_edit.attached_elements.has(node_name):
			node_name = graph_edit.attached_elements.get(node_name)
			list.append(node_name)
		else:
			list.append(&"null")
			break
	return list


func _on_popup_node_context_menu_at_mouse_request(selected_nodes: Array) -> void:
	clear()
	populate(selected_nodes)
	main_editor.node_creation_target = graph_edit.get_local_mouse_position()
	main_editor.move_popup_at_mouse(self)
	popup()



func _group_nodes_in_frame(nodes: Array[StringName]) -> void:
	var front_node: StringName = nodes.front()
	var front_frame_tree: Array[StringName] = _get_node_frame_parents_list(front_node)
	front_frame_tree.reverse()
	for other_node: StringName in nodes:
		var other_frame_tree: Array[StringName] = _get_node_frame_parents_list(other_node)
		other_frame_tree.reverse()
		for i in range(0, mini(front_frame_tree.size(), other_frame_tree.size())):
			if not front_frame_tree[i] == other_frame_tree[i]:
				front_frame_tree.resize(i)

	var matching_parent: StringName = front_frame_tree.back()
	var things_to_group: Array[StringName] = []
	var parent_name: StringName
	for node_name: StringName in nodes:
		var loop_limit: int = 50
		while loop_limit > 0:
			loop_limit -= 1
			parent_name = graph_edit.attached_elements.get(node_name, &"null")
			if parent_name == matching_parent:
				if not things_to_group.has(node_name):
					things_to_group.append(node_name)
				break
			node_name = parent_name

	var positions: Array = things_to_group.map(func(node_name: StringName):
		return (graph_edit.get_node(NodePath(node_name)) as GraphElement).position
	)
	var frame_position: Vector2 = positions.reduce(func(a: Vector2, b: Vector2):
		return a.min(b), positions.front()
	)
	var new_frame_id: int = graph_edit.graph.add_frame(frame_position)
	var new_frame: Node = graph_edit.instantiate_node(new_frame_id)
	var new_frame_name: StringName = new_frame.name

	if matching_parent != &"null":
		graph_edit.attach_graph_element_to_frame(new_frame_name, matching_parent)
		graph_edit._on_element_attached_to_frame(new_frame_name, matching_parent)

		for node_name: StringName in things_to_group:
			graph_edit.detach_element_from_frame(node_name)

	for node_name in things_to_group:
		graph_edit.attach_graph_element_to_frame(node_name, new_frame_name)
		graph_edit._on_element_attached_to_frame(node_name, new_frame_name)

	new_frame.selected = true
