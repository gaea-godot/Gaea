@tool
class_name GaeaEditorPopupFileContextMenu
extends PopupMenu


@export var file_system_container: GaeaEditorFileList


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	clear()
	_add_menu_item(GaeaEditorFileList.Action.SAVE, "Save", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KeyModifierMask.KEY_MASK_ALT | KEY_S)
	_add_menu_item(GaeaEditorFileList.Action.SAVE, "Save As...")

	add_separator()
	_add_menu_item(GaeaEditorFileList.Action.COPY_PATH, "Copy Graph Path")
	_add_menu_item(GaeaEditorFileList.Action.SHOW_IN_FILESYSTEM, "Show in FileSystem")
	_add_menu_item(GaeaEditorFileList.Action.OPEN_IN_INSPECTOR, "Open File in Inspector")

	add_separator()
	_add_menu_item(GaeaEditorFileList.Action.CLOSE, "Close", KeyModifierMask.KEY_MASK_CMD_OR_CTRL | KEY_W)
	_add_menu_item(GaeaEditorFileList.Action.CLOSE_ALL, "Close All")
	_add_menu_item(GaeaEditorFileList.Action.CLOSE_OTHER, "Close Other Tabs")


func _add_menu_item(id: GaeaEditorFileList.Action, text: String, shortcut_key: Variant = KEY_NONE) -> void:
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
			GaeaEditorSettings.get_file_list_action_shortcut(id, shortcut_key)
		)


func _on_about_to_popup() -> void:
	for item_index in item_count:
		var action: GaeaEditorFileList.Action = get_item_id(item_index) as GaeaEditorFileList.Action
		set_item_disabled(item_index, not file_system_container.can_do_action(action))
