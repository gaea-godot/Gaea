@tool
class_name GaeaEditorPopupNodeContextMenu
extends PopupMenu


@export var main_view: GaeaEditorMainView
@export var graph_edit: GaeaEditorGraphEdit


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	hide()


func _on_popup_node_context_menu_at_mouse_request(selected_nodes: Array) -> void:
	clear()
	populate(selected_nodes)
	main_view.node_creation_target = graph_edit.get_local_mouse_position()
	main_view.move_popup_at_mouse(self)
	popup()


func populate(selected: Array) -> void:
	_add_menu_item(GaeaEditorGraphEdit.Action.ADD, "Add Node", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_A)
	add_separator()
	_add_menu_item(GaeaEditorGraphEdit.Action.CUT, "Cut", &"ui_cut")
	_add_menu_item(GaeaEditorGraphEdit.Action.COPY, "Copy", &"ui_copy")
	_add_menu_item(GaeaEditorGraphEdit.Action.PASTE, "Paste", &"ui_paste")

	add_separator()
	_add_menu_item(GaeaEditorGraphEdit.Action.SELECT_ALL, "Select All")
	_add_menu_item(GaeaEditorGraphEdit.Action.DUPLICATE, "Duplicate Selection", &"ui_graph_duplicate")
	_add_menu_item(GaeaEditorGraphEdit.Action.DELETE, "Delete Selection", &"ui_graph_delete")
	_add_menu_item(GaeaEditorGraphEdit.Action.CLEAR_BUFFER, "Clear Copy Buffer")

	add_separator()
	_add_menu_item(
		GaeaEditorGraphEdit.Action.COPY_TO_CLIPBOARD, "Copy to Clipboard",
		KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_SHIFT | KEY_C
	)
	_add_menu_item(
		GaeaEditorGraphEdit.Action.PASTE_FROM_CLIPBOARD, "Paste from Clipboard",
		KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_SHIFT | KEY_V
	)

	if not selected.is_empty():
		add_separator()
		_add_menu_item(GaeaEditorGraphEdit.Action.GROUP_IN_FRAME, "Group in New Frame", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_G)

	for node: GraphElement in selected:
		if graph_edit.attached_elements.has(node.name):
			_add_menu_item(GaeaEditorGraphEdit.Action.DETACH, "Detach from Parent Frame")
			break


	if selected.size() == 1:
		if selected.front() is GaeaEditorGraphFrame:
			add_separator()
			add_item("Rename Frame", GaeaEditorGraphEdit.Action.RENAME)
			add_check_item("Enable Auto Shrink", GaeaEditorGraphEdit.Action.TOGGLE_AUTO_SHRINK)
			add_check_item("Enable Tint Color", GaeaEditorGraphEdit.Action.TOGGLE_TINT)
			add_item("Set Tint Color", GaeaEditorGraphEdit.Action.TINT)

			set_item_checked(get_item_index(GaeaEditorGraphEdit.Action.TOGGLE_TINT), selected.front().tint_color_enabled)
			set_item_checked(
				get_item_index(GaeaEditorGraphEdit.Action.TOGGLE_AUTO_SHRINK), selected.front().autoshrink_enabled
			)
			size = get_contents_minimum_size()

		if selected.front() is GaeaEditorGraphNode:
			var node: GaeaEditorGraphNode = selected.front()

			var resource: GaeaNodeResource = node.resource
			if resource is GaeaNodeParameter:
				var parameter: Dictionary = graph_edit.graph.get_parameter_dictionary(node.get_arg_value("name"))

				if parameter.get("value") is Resource:
					add_separator()
					add_item("Open In Inspector", GaeaEditorGraphEdit.Action.OPEN_IN_INSPECTOR)


	for item_idx: int in item_count:
		@warning_ignore("int_as_enum_without_cast")
		var action: GaeaEditorGraphEdit.Action = get_item_id(item_idx)
		set_item_disabled(item_idx, not graph_edit.can_do_action(action))




func _add_menu_item(id: GaeaEditorGraphEdit.Action, text: String, shortcut_key: Variant = KEY_NONE) -> void:
	add_item(tr(text), id)
	if shortcut_key is StringName and InputMap.has_action(shortcut_key):
		var shortcut = Shortcut.new()
		shortcut.events = InputMap.action_get_events(shortcut_key)
		set_item_shortcut(
			get_item_index(id),
			shortcut
		)
	elif shortcut_key is Key and shortcut_key != KEY_NONE:
		set_item_shortcut(
			get_item_index(id),
			GaeaEditorSettings.get_node_action_shortcut(id, shortcut_key)
		)
