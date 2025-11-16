@tool
class_name GaeaFileList
extends VBoxContainer


const GRAPH_ICON := preload("uid://cerisdpavr7v3")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor
@export var menu_bar: MenuBar
@export var file_list: ItemList
@export var context_menu: GaeaPopupFileContextMenu
@export var file_dialog: FileDialog

var edited_graphs: Array[EditedGraph]
var _current_saving_graph: GaeaGraph = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	file_list.item_selected.connect(_on_item_selected)
	file_list.item_clicked.connect(_on_item_clicked)

	context_menu.close_file_selected.connect(close_file)
	context_menu.close_all_selected.connect(close_all)
	context_menu.close_others_selected.connect(close_others)
	context_menu.save_as_selected.connect(_start_save_as)
	context_menu.file_saved.connect(_on_file_saved)
	context_menu.unsaved_file_found.connect(_on_unsaved_file_found)

	menu_bar.open_file_selected.connect(open_file)
	menu_bar.create_new_graph_selected.connect(_start_new_graph_creation)

	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	file_dialog.canceled.connect(_on_file_dialog_canceled)


#region Opening
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

	_on_item_selected(idx)
	var edited_graph := EditedGraph.new(graph)
	edited_graphs.append(edited_graph)
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


func _on_unsaved_file_found(file: GaeaGraph) -> void:
	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(file))
	if idx == -1:
		return

	file_list.set_item_text(idx, "[unsaved]")
	file_list.set_item_tooltip(idx, "[unsaved]")
	_start_save_as(file)
#endregion


#region Signals
func _on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		main_editor.move_popup_at_mouse(context_menu)
		context_menu.graph = file_list.get_item_metadata(index)
		context_menu.popup()
	elif mouse_button_index == MOUSE_BUTTON_MIDDLE:
		_remove(index)


func _on_item_selected(index: int) -> void:
	if index == -1:
		return

	var metadata: GaeaGraph = file_list.get_item_metadata(index)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	graph_edit.unpopulate()
	graph_edit.populate(metadata)


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
