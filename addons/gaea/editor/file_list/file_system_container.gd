@tool
class_name GaeaFileList
extends VBoxContainer


const GRAPH_ICON := preload("uid://cerisdpavr7v3")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor
@export var menu_bar: MenuBar
@export var file_list: Tree
@export var context_menu: GaeaPopupFileContextMenu
@export var file_dialog: FileDialog

var edited_graphs: Array[EditedGraph]
var _current_saving_graph: GaeaGraph = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	file_list.item_selected.connect(_on_item_selected)
	file_list.gui_input.connect(_on_file_list_gui_input)
	file_list.create_item()
	file_list.hide_root = true
	file_list.set_column_expand(1, false)

	graph_edit.subgraph_opened.connect(_on_subgraph_opened)

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
func open_file(graph: GaeaGraph, parent: GaeaGraph = null) -> void:
	if not is_instance_valid(graph):
		return

	if not is_instance_valid(parent):
		menu_bar.add_graph_to_history(graph)

	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(graph))
	var item: TreeItem
	if idx != -1:
		var edited_graph := edited_graphs[idx]
		item = edited_graph.get_tree_item()
		if item.get_metadata(0) == graph:
			if not item.is_selected(0):
				item.select(0)
				file_list.item_selected.emit()
			return

	var parent_item: TreeItem = null
	if is_instance_valid(parent):
		parent_item = edited_graphs[
			edited_graphs.find_custom(EditedGraph.is_graph.bind(parent))
		].get_tree_item()
	item = _create_item_for_graph(graph, parent_item)
	_on_item_selected()
	var new_edited_graph := EditedGraph.new(graph, item)
	item.set_metadata(1, new_edited_graph)
	edited_graphs.append(new_edited_graph)
	new_edited_graph.dirty_changed.connect(_on_edited_graph_dirty_changed.bind(new_edited_graph))


func _create_item_for_graph(graph: GaeaGraph, parent: TreeItem = null) -> TreeItem:
	var item := file_list.create_item(parent)
	item.set_metadata(0, graph)
	item.set_text(
		0, graph.resource_path.get_file() if not graph.resource_path.is_empty() else "[unsaved]"
	)
	item.set_icon(0, GRAPH_ICON)
	item.set_tooltip_text(0, graph.resource_path)
	item.select(0)
	return item

#endregion


#region Closing
func close_file(graph: GaeaGraph) -> void:
	var idx: int = edited_graphs.find_custom(EditedGraph.is_graph.bind(graph))
	_remove(edited_graphs[idx])


func close_all() -> void:
	for idx: int in range(edited_graphs.size() - 1, -1, -1):
		close_file(edited_graphs[idx].get_graph())


func close_others(graph: GaeaGraph) -> void:
	for edited_graph: EditedGraph in edited_graphs.duplicate():
		var file := edited_graph.get_graph()
		if file == graph:
			continue

		close_file(file)


func _remove(edited_graph: EditedGraph) -> void:
	if not is_instance_valid(edited_graph) or not (edited_graph in edited_graphs):
		return

	var graph: GaeaGraph = edited_graph.get_tree_item().get_metadata(0)
	for child in edited_graph.get_tree_item().get_children():
		_remove(child.get_metadata(1))

	edited_graph.get_tree_item().get_parent().remove_child(edited_graph.get_tree_item())
	edited_graphs.erase(edited_graph)
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

	var item := edited_graphs[idx].get_tree_item()
	item.set_text(0, "[unsaved]")
	item.set_tooltip_text(0, "")
	_start_save_as(file)


func _on_subgraph_opened(subgraph: GaeaSubGraph, parent: GaeaGraph) -> void:
	if not subgraph.is_built_in():
		parent = null
	open_file(subgraph, parent)
#endregion


#region Signal
func _on_item_selected() -> void:
	var item := file_list.get_selected()

	var metadata: GaeaGraph = item.get_metadata(0)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	graph_edit.unpopulate()
	graph_edit.populate(metadata)


func _on_file_list_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	if not event.is_pressed():
		return

	var item := file_list.get_item_at_position(event.position)
	if not is_instance_valid(item):
		return

	if event.button_index == MOUSE_BUTTON_MIDDLE:
		_remove(item.get_metadata(1))
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		main_editor.move_popup_at_mouse(context_menu)
		context_menu.graph = item.get_metadata(0)
		context_menu.popup()


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
	var text := edited_graph.get_tree_item().get_text(0)
	text = text.trim_suffix("(*)")
	if new_value == true:
		text += "(*)"
	edited_graph.get_tree_item().set_text(0, text)
#endregion


class EditedGraph extends RefCounted:
	signal dirty_changed(new_value: bool)

	var _graph: GaeaGraph : get = get_graph
	var _dirty: bool = false : set = set_dirty, get = is_unsaved
	var _tree_item: TreeItem : get = get_tree_item


	static func is_graph(edited_graph: EditedGraph, graph: GaeaGraph) -> bool:
		return edited_graph.get_graph() == graph


	func _init(graph: GaeaGraph, tree_item: TreeItem) -> void:
		_graph = graph
		_graph.changed.connect(set_dirty.bind(true))
		_tree_item = tree_item


	func set_dirty(value: bool) -> void:
		var prev_value: bool = _dirty
		_dirty = value
		if prev_value != _dirty:
			dirty_changed.emit(_dirty)


	func is_unsaved() -> bool:
		return _dirty


	func get_graph() -> GaeaGraph:
		return _graph


	func get_tree_item() -> TreeItem:
		return _tree_item
