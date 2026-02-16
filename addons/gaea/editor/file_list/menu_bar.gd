@tool
class_name GaeaFileListMenuBar
extends MenuBar

signal recent_file_selected(graph: GaeaGraph)

@export var file_popup: PopupMenu
@export var recent_files: PopupMenu
@export var edit_popup: PopupMenu
@export var graph_edit: GaeaGraphEdit
@export var file_system_container: GaeaFileList


var _history: Array[GaeaGraph]


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_populate_file_popup_menu()
	_populate_edit_popup_menu()
	update_menu_enabled_state()


#region File menu
func _populate_file_popup_menu() -> void:
	_add_file_menu_item(GaeaFileList.Action.NEW_GRAPH, "New Graph...", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_N)
	_add_file_menu_item(GaeaFileList.Action.OPEN, "Open...", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_O)
	file_popup.add_submenu_node_item("Open Recent", recent_files, GaeaFileList.Action.OPEN_RECENT)

	file_popup.add_separator()
	_add_file_menu_item(GaeaFileList.Action.SAVE, "Save", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_ALT | KEY_S)
	_add_file_menu_item(GaeaFileList.Action.SAVE, "Save As...")

	file_popup.add_separator()
	_add_file_menu_item(GaeaFileList.Action.COPY_PATH, "Copy Graph Path")
	_add_file_menu_item(GaeaFileList.Action.SHOW_IN_FILESYSTEM, "Show in FileSystem")
	_add_file_menu_item(GaeaFileList.Action.OPEN_IN_INSPECTOR, "Open File in Inspector")

	file_popup.add_separator()
	_add_file_menu_item(GaeaFileList.Action.CLOSE, "Close", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_W)
	_add_file_menu_item(GaeaFileList.Action.CLOSE_ALL, "Close All")
	_add_file_menu_item(GaeaFileList.Action.CLOSE_OTHER, "Close Other Tabs")


func _add_file_menu_item(id: GaeaFileList.Action, text: String, shortcut_key: int = KEY_NONE) -> void:
	file_popup.add_item(tr(text), id)
	if shortcut_key != KEY_NONE:
		file_popup.set_item_shortcut(
			file_popup.get_item_index(id),
			GaeaEditorSettings.get_file_list_action_shortcut(id, shortcut_key)
		)


func is_history_empty() -> int:
	return _history.is_empty()


func add_graph_to_history(new_graph: GaeaGraph) -> void:
	if _history.has(new_graph):
		_history.erase(new_graph)

	_history.push_front(new_graph)
	if _history.size() > 10:
		_history.resize(10)

	recent_files.clear()
	for idx in _history.size():
		var graph := _history[idx]
		recent_files.add_item(graph.resource_path.get_file())
		recent_files.set_item_metadata(idx, graph)
		recent_files.set_item_tooltip(idx, graph.resource_path)


func _on_recent_files_id_pressed(id: int) -> void:
	recent_file_selected.emit(
		recent_files.get_item_metadata(recent_files.get_item_index(id))
	)


func _on_file_item_about_to_popup() -> void:
	file_popup.set_item_disabled(file_popup.get_item_index(GaeaFileList.Action.OPEN_RECENT), _history.is_empty())
#endregion

#region Edit menu
func _populate_edit_popup_menu() -> void:
	_add_edit_menu_item(GaeaGraphEdit.Action.ADD, "Add Node", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_A)
	edit_popup.add_separator()
	_add_edit_menu_item(GaeaGraphEdit.Action.CUT, "Cut", &"ui_cut")
	_add_edit_menu_item(GaeaGraphEdit.Action.COPY, "Copy", &"ui_copy")
	_add_edit_menu_item(GaeaGraphEdit.Action.PASTE, "Paste", &"ui_paste")
	edit_popup.add_separator()
	_add_edit_menu_item(GaeaGraphEdit.Action.SELECT_ALL, "Select All")
	_add_edit_menu_item(GaeaGraphEdit.Action.DUPLICATE, "Duplicate Selection", &"ui_graph_duplicate")
	_add_edit_menu_item(GaeaGraphEdit.Action.DELETE, "Delete Selection", &"ui_graph_delete")
	_add_edit_menu_item(GaeaGraphEdit.Action.CLEAR_BUFFER, "Clear Copy Buffer")

	edit_popup.add_separator()
	_add_edit_menu_item(
		GaeaGraphEdit.Action.COPY_TO_CLIPBOARD, "Copy to Clipboard",
		KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_SHIFT | KEY_C
	)
	_add_edit_menu_item(
		GaeaGraphEdit.Action.PASTE_FROM_CLIPBOARD, "Paste from Clipboard",
		KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_SHIFT | KEY_V
	)

	edit_popup.add_separator()
	_add_edit_menu_item(GaeaGraphEdit.Action.GROUP_IN_FRAME, "Group Selection in New Frame", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_G)

	_add_edit_menu_item(GaeaGraphEdit.Action.DETACH, "Detach from Parent Frame")


func _add_edit_menu_item(id: GaeaGraphEdit.Action, text: String, shortcut_key: Variant = KEY_NONE) -> void:
	edit_popup.add_item(tr(text), id)
	if shortcut_key is StringName and InputMap.has_action(shortcut_key):
		var shortcut = Shortcut.new()
		shortcut.events = InputMap.action_get_events(shortcut_key)
		edit_popup.set_item_shortcut(
			edit_popup.get_item_index(id),
			shortcut
		)
	elif shortcut_key is Key and shortcut_key != KEY_NONE:
		edit_popup.set_item_shortcut(
			edit_popup.get_item_index(id),
			GaeaEditorSettings.get_node_action_shortcut(id, shortcut_key)
		)
#endregion


func update_menu_enabled_state() -> void:
	for item_index in edit_popup.item_count:
		var action: GaeaGraphEdit.Action = edit_popup.get_item_id(item_index) as GaeaGraphEdit.Action
		var disabled: bool = not graph_edit.can_do_action(action)
		edit_popup.set_item_disabled(item_index, disabled)
		edit_popup.set_item_shortcut_disabled(item_index, disabled)

	for item_index in file_popup.item_count:
		var action: GaeaFileList.Action = file_popup.get_item_id(item_index) as GaeaFileList.Action
		var disabled: bool = not file_system_container.can_do_action(action)
		file_popup.set_item_disabled(item_index, disabled)
		file_popup.set_item_shortcut_disabled(item_index, disabled)
