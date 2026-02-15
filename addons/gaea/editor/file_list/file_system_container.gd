@tool
class_name GaeaFileList
extends VBoxContainer

enum Action {
	NEW_GRAPH,
	OPEN,
	OPEN_RECENT,
	SAVE,
	SAVE_AS,
	CLOSE,
	CLOSE_ALL,
	CLOSE_OTHER,
	COPY_PATH,
	SHOW_IN_FILESYSTEM,
	OPEN_IN_INSPECTOR,
}


const GRAPH_ICON := preload("uid://cerisdpavr7v3")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor
@export var menu_bar: GaeaFileListMenuBar
@export var file_list: ItemList
@export var context_menu: GaeaPopupFileContextMenu
@export var file_dialog: FileDialog

var edited_graphs: Array[EditedGraph]
var _current_saving_graph: GaeaGraph = null



#region Opening
func open_file_from_path(path: String) -> void:
	if not path.is_empty():
		open_file(load(path))


func open_file(graph: GaeaGraph) -> void:
	if not is_instance_valid(graph):
		return

	menu_bar.add_graph_to_history(graph)

	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(graph))
	if idx != -1:
		if file_list.get_item_metadata(idx) == graph:
			if not file_list.is_selected(idx):
				file_list.select(idx)
				file_list.item_selected.emit(idx)
			return

	idx = file_list.add_item(graph.resource_path.get_file(), GRAPH_ICON)
	file_list.set_item_metadata(idx, graph)
	file_list.set_item_tooltip(idx, graph.resource_path)
	file_list.select(idx)

	var edited_graph := EditedGraph.new(graph)
	edited_graphs.append(edited_graph)
	_on_item_selected(idx)
	edited_graph.dirty_changed.connect(_on_edited_graph_dirty_changed.bind(edited_graph))
#endregion


#region Closing
func close_file(graph: GaeaGraph) -> void:
	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(graph))
	if file_list.get_item_metadata(idx) == graph:
		_remove(idx)


func close_all() -> void:
	for idx: int in range(edited_graphs.size() - 1, -1, -1):
		close_file(edited_graphs[idx].get_graph())


func close_others(graph: GaeaGraph) -> void:
	for edited_graph: EditedGraph in edited_graphs.duplicate():
		var file := edited_graph.get_graph()
		if file == graph:
			continue

		close_file(file)


func _remove(idx: int) -> void:
	var graph: GaeaGraph = file_list.get_item_metadata(idx)
	file_list.remove_item(idx)
	edited_graphs.remove_at(
		edited_graphs.find_custom(EditedGraph.is_graph.bind(graph))
	)
	if graph_edit.graph == graph:
		graph_edit.unpopulate()
#endregion


#region Saving
func save(file: GaeaGraph) -> void:
	if file.resource_path.is_empty():
		_on_unsaved_file_found(file)
		return

	if not file.is_built_in():
		ResourceSaver.save(file)
	else:
		var scene_path := file.resource_path.get_slice("::", 0)
		ResourceSaver.save(load(scene_path))
		# Necessary for open scenes.
		EditorInterface.reload_scene_from_path(scene_path)
	_on_file_saved(file)


func _start_save_as(file: GaeaGraph) -> void:
	file_dialog.title = "Save Graph As..."
	var path: String = "res://"
	if not file.is_built_in() and not file.resource_path.is_empty():
		path = file.resource_path

	file_dialog.current_path = path
	file_dialog.popup_centered()

	_current_saving_graph = file


func _start_new_graph_creation() -> void:
	file_dialog.title = "New Graph..."
	if file_dialog.current_path.get_extension() != "tres":
		file_dialog.current_path = "%s/new_graph.tres" % file_dialog.current_path.get_base_dir()
	file_dialog.popup_centered()


func _on_file_saved(file: GaeaGraph) -> void:
	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(file))
	if idx == -1:
		return

	edited_graphs[idx].set_dirty(false)


func set_unsaved(file: GaeaGraph) -> void:
	file.resource_path = ""

	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(file))
	if idx == -1:
		return

	file_list.set_item_text(idx, "[unsaved]")
	file_list.set_item_tooltip(idx, "[unsaved]")


func _on_unsaved_file_found(file: GaeaGraph) -> void:
	set_unsaved(file)
	_start_save_as(file)
#endregion


#region Signals
func _on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		main_editor.move_popup_at_mouse(context_menu)
		context_menu.popup()
	elif mouse_button_index == MOUSE_BUTTON_MIDDLE:
		_remove(index)


func _on_item_selected(index: int) -> void:
	if index == -1:
		return

	var metadata: GaeaGraph = file_list.get_item_metadata(index)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	if graph_edit.graph != metadata:
		graph_edit.unpopulate()
		graph_edit.populate(metadata)

	var edited: Object = EditorInterface.get_inspector().get_edited_object()
	if edited is not GaeaGenerator or (edited as GaeaGenerator).graph != metadata:
		EditorInterface.inspect_object.call_deferred(metadata)


func _on_file_dialog_file_selected(path: String) -> void:
	var extension: String = path.get_extension()
	if extension.is_empty():
		if not path.ends_with("."):
			path += "."
		path += "tres"
	elif extension != "tres":
		push_error("Invalid extension for a GaeaGraph file.")
		return

	var new_graph: GaeaGraph

	if is_instance_valid(_current_saving_graph):
		close_file(_current_saving_graph)
		new_graph = _current_saving_graph
	else:
		new_graph = GaeaGraph.new()

	new_graph.take_over_path(path)
	ResourceSaver.save(new_graph, path)
	open_file(load(path))
	_current_saving_graph = null


func _on_file_dialog_canceled() -> void:
	_current_saving_graph = null


func _on_edited_graph_dirty_changed(new_value: bool, edited_graph: EditedGraph) -> void:
	var idx := edited_graphs.find(edited_graph)
	if idx == -1:
		return

	var text := file_list.get_item_text(idx)
	text = text.trim_suffix("(*)")
	if new_value == true:
		text += "(*)"
	file_list.set_item_text(idx, text)


func can_do_action(id: Action) -> bool:
	match id:
		Action.NEW_GRAPH, Action.OPEN:
			return true
		Action.OPEN_RECENT:
			return not menu_bar.is_history_empty()
		_:
			return not edited_graphs.is_empty()


func _on_action_pressed(id: Action) -> void:
	match id:
		Action.NEW_GRAPH:
			_start_new_graph_creation()
		Action.OPEN:
			EditorInterface.popup_quick_open(open_file_from_path, [&"GaeaGraph"])
		Action.SAVE:
			save(graph_edit.graph)
		Action.SAVE_AS:
			_start_save_as(graph_edit.graph)
		Action.CLOSE:
			close_file(graph_edit.graph)
		Action.CLOSE_ALL:
			close_all()
		Action.CLOSE_OTHER:
			close_others(graph_edit.graph)
		Action.COPY_PATH:
			DisplayServer.clipboard_set(graph_edit.graph.resource_path)
		Action.SHOW_IN_FILESYSTEM:
			if not graph_edit.graph.is_built_in():
				EditorInterface.select_file(graph_edit.graph.resource_path)
			else:
				EditorInterface.select_file(graph_edit.graph.resource_path.get_slice("::", 0))
		Action.OPEN_IN_INSPECTOR:
			EditorInterface.edit_resource(graph_edit.graph)
#endregion


class EditedGraph extends RefCounted:
	signal dirty_changed(new_value: bool)

	var _graph: GaeaGraph : get = get_graph
	var _dirty: bool = false : set = set_dirty, get = is_unsaved


	static func is_graph(edited_graph: EditedGraph, graph: GaeaGraph) -> bool:
		return edited_graph.get_graph() == graph


	func _init(graph: GaeaGraph) -> void:
		_graph = graph
		_graph.changed.connect(set_dirty.bind(true))


	func set_dirty(value: bool) -> void:
		var prev_value: bool = _dirty
		_dirty = value
		if prev_value != _dirty:
			dirty_changed.emit(_dirty)


	func is_unsaved() -> bool:
		return _dirty


	func get_graph() -> GaeaGraph:
		return _graph
