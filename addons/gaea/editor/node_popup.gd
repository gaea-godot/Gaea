@tool
extends PopupMenu


enum Action {
	ADD,
	DELETE,
	RENAME,
	ENABLE_TINT,
	TINT,
	DETACH,
	ENABLE_AUTO_SHRINK,
	OPEN_IN_INSPECTOR
}

@export var panel: Control
@export var graph_edit: GraphEdit

signal create_node_popup_requested


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	hide()
	id_pressed.connect(_on_id_pressed)


func populate(selected: Array) -> void:
	add_item("Add Node", Action.ADD)
	add_separator()
	add_item("Delete", Action.DELETE)
	for node: GraphElement in selected:
		if graph_edit.attached_elements.has(node.name):
			add_item("Detach from Parent Frame", Action.DETACH)
			break
	if selected.front() is GaeaGraphFrame and selected.size() == 1:
		add_separator()
		add_item("Rename Frame", Action.RENAME)
		add_check_item("Enable Auto Shrink", Action.ENABLE_AUTO_SHRINK)
		add_check_item("Enable Tint Color", Action.ENABLE_TINT)
		add_item("Set Tint Color", Action.TINT)
		set_item_disabled(get_item_index(Action.TINT), not selected.front().tint_color_enabled)

		set_item_checked(get_item_index(Action.ENABLE_TINT), selected.front().tint_color_enabled)
		set_item_checked(get_item_index(Action.ENABLE_AUTO_SHRINK), selected.front().autoshrink_enabled)
		size = get_contents_minimum_size()
	if selected.front() is GaeaGraphNode and selected.size() == 1:
		var node: GaeaGraphNode = selected.front()
		var resource: GaeaNodeResource = node.resource
		if resource is GaeaNodeParameter:
			var data: GaeaGraph = panel.get_selected_generator().data
			var parameter: Dictionary = data.get_parameter_dictionary(node.get_arg_value("name"))
			if parameter.get("value") is Resource:
				add_separator()
				add_item("Open In Inspector", Action.OPEN_IN_INSPECTOR)


func _on_id_pressed(id: int) -> void:
	var idx: int = get_item_index(id)
	match id:
		Action.ADD:
			create_node_popup_requested.emit()
		Action.DELETE:
			graph_edit.delete_nodes(graph_edit.get_selected_names())

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
				node.generator.data.set_node_data_value(&"tint_color_enabled", is_item_checked(idx), node.id)
		Action.ENABLE_AUTO_SHRINK:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GaeaGraphFrame:
				node.set_autoshrink_enabled(is_item_checked(idx))
		Action.DETACH:
			var selected: Array = graph_edit.get_selected()
			for node: GraphElement in selected:
				if graph_edit.attached_elements.has(node.name):
					graph_edit.detach_element_from_frame(node.name)
		Action.OPEN_IN_INSPECTOR:
			var node: GaeaGraphNode = graph_edit.get_selected().front()
			var resource: GaeaNodeResource = node.resource
			if resource is GaeaNodeParameter:
				var data: GaeaGraph = panel.get_selected_generator().data
				var parameter: Dictionary = data.get_parameter_dictionary(node.get_arg_value("name"))
				var value: Variant = parameter.get("value")
				if value is Resource and is_instance_valid(value):
					EditorInterface.edit_resource(value)
