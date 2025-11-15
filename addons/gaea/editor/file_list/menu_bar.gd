@tool
extends MenuBar


signal open_file_selected(file: GaeaGraph)
signal create_new_graph_selected

enum Action {
	NEW_GRAPH,
	OPEN,
	OPEN_RECENT,
}

var _history: Array[GaeaGraph]

@onready var file_popup: PopupMenu = $File
@onready var recent_files: PopupMenu = $File/RecentFiles


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	file_popup.add_item("New Graph...", Action.NEW_GRAPH)
	file_popup.add_item("Open...", Action.OPEN)
	file_popup.add_submenu_node_item("Open Recent", recent_files, Action.OPEN_RECENT)
	file_popup.id_pressed.connect(_on_id_pressed)
	file_popup.about_to_popup.connect(_on_file_item_about_to_popup)

	recent_files.id_pressed.connect(_on_recent_files_id_pressed)


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


func _on_id_pressed(id: int) -> void:
	match id:
		Action.NEW_GRAPH:
			create_new_graph_selected.emit()
		Action.OPEN:
			EditorInterface.popup_quick_open(_on_file_chosen_to_open, [&"GaeaGraph"])


func _on_file_chosen_to_open(path: String) -> void:
	if path.is_empty():
		return
	open_file_selected.emit(load(path))


func _on_recent_files_id_pressed(id: int) -> void:
	open_file_selected.emit(
		recent_files.get_item_metadata(recent_files.get_item_index(id))
	)


func _on_file_item_about_to_popup() -> void:
	file_popup.set_item_disabled(2, _history.is_empty())
