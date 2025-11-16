@tool
class_name GaeaPopupFileContextMenu
extends PopupMenu


signal close_file_selected(file: GaeaGraph)
signal close_all_selected
signal close_others_selected(file: GaeaGraph)
signal save_as_selected(file: GaeaGraph)
signal file_saved(file: GaeaGraph)
signal unsaved_file_found(file: GaeaGraph)

enum Action {
	SAVE,
	SAVE_AS,
	CLOSE,
	CLOSE_ALL,
	CLOSE_OTHER,
	COPY_PATH,
	SHOW_IN_FILESYSTEM,
	OPEN_IN_INSPECTOR
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
	add_item("Close Other Tabs", Action.CLOSE_OTHER)
	add_separator()
	add_item("Copy File Path", Action.COPY_PATH)
	add_item("Show in FileSystem", Action.SHOW_IN_FILESYSTEM)
	add_item("Open File in Inspector", Action.OPEN_IN_INSPECTOR)

	id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id: int) -> void:
	match id:
		Action.SAVE:
			if graph.resource_path.is_empty():
				unsaved_file_found.emit(graph)
				return

			if not graph.is_built_in():
				ResourceSaver.save(graph)
			else:
				var scene_path := graph.resource_path.get_slice("::", 0)
				ResourceSaver.save(load(scene_path))
				# Necessary for open scenes.
				EditorInterface.reload_scene_from_path(scene_path)
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
			else:
				EditorInterface.select_file(graph.resource_path.get_slice("::", 0))
		Action.OPEN_IN_INSPECTOR:
			EditorInterface.edit_resource(graph)
