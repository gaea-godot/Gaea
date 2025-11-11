@tool
class_name GaeaFileList
extends VBoxContainer


const GRAPH_ICON := preload("res://addons/gaea/assets/graph.svg")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor

var edited_graphs: Array[GaeaGraph]

@onready var menu_bar: MenuBar = $MenuBar
@onready var file_list: ItemList = $FileList
@onready var context_menu: GaeaPopupFileContextMenu = $FileList/ContextMenu


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	file_list.item_selected.connect(_on_item_selected)
	file_list.item_clicked.connect(_on_item_clicked)

	context_menu.close_file_selected.connect(close_file)
	context_menu.close_all_selected.connect(close_all)
	context_menu.close_others_selected.connect(close_others)
	menu_bar.open_file_selected.connect(open_file)


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
