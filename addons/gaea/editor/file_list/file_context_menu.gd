@tool
class_name GaeaPopupFileContextMenu
extends PopupMenu


signal close_file_selected(file: GaeaGraph)
signal close_all_selected
signal close_others_selected(file: GaeaGraph)
signal save_as_selected(file: GaeaGraph)
signal file_saved(file: GaeaGraph)

enum Action {
	SAVE,
	SAVE_AS,
	CLOSE,
	CLOSE_ALL,
	CLOSE_OTHER,
	COPY_PATH,
	SHOW_IN_FILESYSTEM
}

var graph: GaeaGraph

func _ready() -> void:
	if is_part_of_edited_scene():
		return

	clear()
	add_item("Save File", Action.SAVE)
	add_item("Save File As...", Action.SAVE_AS)
	add_item("Close", Action.CLOSE)
	add_item("Close All", Action.CLOSE_ALL)
	add_item("Close Other", Action.CLOSE_OTHER)
	add_separator()
	add_item("Copy File Path", Action.COPY_PATH)
	add_item("Show in FileSystem", Action.SHOW_IN_FILESYSTEM)

	id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id: int) -> void:
	match id:
		Action.SAVE:
			ResourceSaver.save(graph)
			file_saved.emit(graph)
		Action.SAVE_AS:
			save_as_selected.emit(graph)
		Action.CLOSE:
			close_file_selected.emit(graph)
		Action.CLOSE_ALL:
			close_all_selected.emit()
		Action.CLOSE_OTHER:
			close_others_selected.emit(graph)
		Action.COPY_PATH:
			DisplayServer.clipboard_set(graph.resource_path)
		Action.SHOW_IN_FILESYSTEM:
			if not graph.is_built_in():
				EditorInterface.select_file(graph.resource_path)
