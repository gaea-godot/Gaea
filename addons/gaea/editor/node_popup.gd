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
	if selected.front() is GraphFrame and selected.size() == 1:
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
			var parameter: Dictionary = data.parameters.get(node.get_arg_value("name"), {})
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
			if node is GraphFrame:
				var line_edit: LineEdit = LineEdit.new()
				line_edit.text = node.title
				line_edit.select_all()
				line_edit.expand_to_text_length = true
				line_edit.position = owner.get_local_mouse_position()
				line_edit.text_submitted.connect(node.set_title)
				line_edit.text_submitted.connect(line_edit.queue_free.unbind(1), CONNECT_DEFERRED)
				line_edit.focus_exited.connect(line_edit.queue_free)
				owner.add_child(line_edit)
				line_edit.grab_click_focus()
				line_edit.grab_focus()

		Action.TINT:
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				var _popup: PopupPanel = PopupPanel.new()
				_popup.position = owner.get_global_mouse_position() as Vector2i

				var vbox_container: VBoxContainer = VBoxContainer.new()

				var color_picker: ColorPicker = ColorPicker.new()
				color_picker.color_changed.connect(node.set_tint_color)
				color_picker.color = node.tint_color

				var ok_button: Button = Button.new()
				ok_button.text = "OK"
				ok_button.pressed.connect(_popup.queue_free)

				vbox_container.add_child(color_picker)
				vbox_container.add_child(ok_button)

				_popup.add_child(vbox_container)

				owner.add_child(_popup)
				_popup.popup()
		Action.ENABLE_TINT:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				node.set_tint_color_enabled(is_item_checked(idx))
		Action.ENABLE_AUTO_SHRINK:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				node.set_autoshrink_enabled(is_item_checked(idx))
		Action.DETACH:
			var selected: Array = graph_edit.get_selected()
			for node: GraphElement in selected:
				if graph_edit.attached_elements.has(node.name):
					graph_edit.detach_graph_element_from_frame(node.name)
					graph_edit.attached_elements.erase(node.name)
		Action.OPEN_IN_INSPECTOR:
			var node: GaeaGraphNode = graph_edit.get_selected().front()
			var resource: GaeaNodeResource = node.resource
			if resource is GaeaNodeParameter:
				var data: GaeaGraph = panel.get_selected_generator().data
				var parameter: Dictionary = data.parameters.get(node.get_arg_value("name"), {})
				var value: Variant = parameter.get("value")
				if value is Resource and is_instance_valid(value):
					EditorInterface.edit_resource(value)
