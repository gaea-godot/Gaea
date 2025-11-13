@tool
class_name GaeaFileList
extends VBoxContainer


const GRAPH_ICON := preload("res://addons/gaea/assets/graph.svg")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor

var edited_graphs: Array[GaeaGraph]
var _current_saving_graph: GaeaGraph = null

@onready var menu_bar: MenuBar = $MenuBar
@onready var file_list: ItemList = $FileList
@onready var context_menu: GaeaPopupFileContextMenu = $FileList/ContextMenu
@onready var file_dialog: FileDialog = $FileDialog


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	file_list.item_selected.connect(_on_item_selected)
	file_list.item_clicked.connect(_on_item_clicked)

	context_menu.close_file_selected.connect(close_file)
	context_menu.close_all_selected.connect(close_all)
	context_menu.close_others_selected.connect(close_others)
	context_menu.save_as_selected.connect(_start_save_as)

	menu_bar.open_file_selected.connect(open_file)
	menu_bar.create_new_graph_selected.connect(_start_new_graph_creation)

	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	file_dialog.canceled.connect(_on_file_dialog_canceled)


#region Opening
func open_file(graph: GaeaGraph) -> void:
	if not is_instance_valid(graph):
		return

	menu_bar.add_graph_to_history(graph)

	if edited_graphs.has(graph):
		var idx: int = edited_graphs.find(graph)
		if file_list.get_item_metadata(idx) == graph:
			if not file_list.is_selected(idx):
				file_list.select(idx)
				file_list.item_selected.emit(idx)
			return

	var new_item_idx := file_list.add_item(graph.resource_path.get_file(), GRAPH_ICON)
	file_list.set_item_metadata(new_item_idx, graph)
	file_list.set_item_tooltip(new_item_idx, graph.resource_path)
	file_list.select(new_item_idx)

	_on_item_selected(new_item_idx)
	edited_graphs.append(graph)
#endregion


#region Closing
func close_file(graph: GaeaGraph) -> void:
	var idx: int = edited_graphs.find(graph)
	if file_list.get_item_metadata(idx) == graph:
		_remove(idx)


func close_all() -> void:
	for file in edited_graphs.duplicate():
		close_file(file)


func close_others(graph: GaeaGraph) -> void:
	for file in edited_graphs.duplicate():
		if file == graph:
			continue

		close_file(file)


func _remove(idx: int) -> void:
	var graph: GaeaGraph = file_list.get_item_metadata(idx)
	file_list.remove_item(idx)
	edited_graphs.erase(graph)
	if graph_edit.graph == graph:
		graph_edit.unpopulate()
#endregion


#region Saving
func _start_save_as(file: GaeaGraph) -> void:
	file_dialog.title = "Save Graph As..."
	var path: String = "res://"
	if not file.is_built_in():
		path = file.resource_path

	file_dialog.current_path = path
	file_dialog.popup_centered()

	_current_saving_graph = file


func _start_new_graph_creation() -> void:
	file_dialog.title = "New Graph..."
	if file_dialog.current_path.get_extension() != "tres":
		file_dialog.current_path = "%s/new_graph.tres" % file_dialog.current_path.get_base_dir()
	file_dialog.popup_centered()
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
	var metadata: GaeaGraph = file_list.get_item_metadata(index)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	graph_edit.unpopulate()
	graph_edit.populate(metadata)
	EditorInterface.edit_resource(metadata)


func _on_file_dialog_file_selected(path: String) -> void:
	var extension: String = path.get_extension()
	if extension.is_empty():
		if not path.ends_with("."):
			path += "."
		path += "tres"
	elif extension != "tres":
		push_error("Invalid extension for a GaeaGraph file.")
		return

	if is_instance_valid(_current_saving_graph):
		close_file(_current_saving_graph)
		ResourceSaver.save(_current_saving_graph, path)
	else:
		ResourceSaver.save(GaeaGraph.new(), path)
	open_file(load(path))
	_current_saving_graph = null


func _on_file_dialog_canceled() -> void:
	_current_saving_graph = null
#endregion
