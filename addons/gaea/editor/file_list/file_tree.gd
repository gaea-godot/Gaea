@tool
class_name GaeaFileList
extends ItemList

const GRAPH_ICON := preload("res://addons/gaea/assets/graph.svg")

@export var graph_edit: GaeaGraphEdit
@export var main_editor: GaeaMainEditor

var edited_graphs: Array[GaeaGraph]

@onready var context_menu: PopupMenu = $ContextMenu


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	item_selected.connect(_on_item_selected)
	item_clicked.connect(_on_item_clicked)


func open_file(graph: GaeaGraph) -> void:
	if edited_graphs.has(graph):
		var idx: int = edited_graphs.find(graph)
		if get_item_metadata(idx) == graph:
			if not is_selected(idx):
				select(idx)
				_on_item_selected(idx)
			return

	var new_item_idx := add_item(graph.resource_path.get_file(), GRAPH_ICON)
	set_item_metadata(new_item_idx, graph)
	set_item_tooltip(new_item_idx, graph.resource_path)
	select(new_item_idx)
	_on_item_selected(new_item_idx)
	edited_graphs.append(graph)


func close_file(graph: GaeaGraph) -> void:
	var idx: int = edited_graphs.find(graph)
	if get_item_metadata(idx) == graph:
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
	var graph: GaeaGraph = get_item_metadata(idx)
	remove_item(idx)
	edited_graphs.erase(graph)
	if graph_edit.graph == graph:
		graph_edit.unpopulate()


func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return

	main_editor.move_popup_at_mouse(context_menu)
	context_menu.graph = get_item_metadata(index)
	context_menu.popup()


func _on_item_selected(index: int) -> void:
	var metadata: GaeaGraph = get_item_metadata(index)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	graph_edit.unpopulate()
	graph_edit.populate(metadata)
	EditorInterface.edit_resource(metadata)
