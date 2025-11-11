@tool
class_name GaeaPopupFileContextMenu
extends PopupMenu


enum Action {
	SAVE,
	SAVE_AS,
	CLOSE,
	CLOSE_ALL,
	CLOSE_OTHER,
	COPY_PATH,
	SHOW_IN_FILESYSTEM
}


var _file_list: GaeaFileList
var graph: GaeaGraph


func _ready() -> void:
	_file_list = get_parent()
	add_item("Save File", Action.SAVE)
	add_item("Save File As...", Action.SAVE_AS)
	add_item("Close File", Action.CLOSE)
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
		Action.SAVE_AS:
			pass
		Action.CLOSE:
			_file_list.close_file(graph)
		Action.CLOSE_ALL:
			_file_list.close_all()
