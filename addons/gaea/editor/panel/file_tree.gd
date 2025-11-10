@tool
class_name GaeaFileList
extends ItemList

const GRAPH_ICON := preload("res://addons/gaea/assets/graph.svg")

@export var graph_edit: GaeaGraphEdit

var edited_graphs: Array[GaeaGraph]


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	item_selected.connect(_on_item_selected)


func open_file(graph: GaeaGraph) -> void:
	for idx in item_count:
		if get_item_metadata(idx) == graph:
			select(idx)
			_on_item_selected(idx)
			return

	var new_item_idx := add_item(graph.resource_path.get_file(), GRAPH_ICON)
	set_item_metadata(new_item_idx, graph)
	set_item_tooltip(new_item_idx, graph.resource_path)
	select(new_item_idx)
	_on_item_selected(new_item_idx)
	edited_graphs.append(graph)


func _on_item_selected(index: int) -> void:
	var metadata: GaeaGraph = get_item_metadata(index)
	if metadata is not GaeaGraph or not is_instance_valid(metadata):
		return

	graph_edit.unpopulate()
	graph_edit.populate(metadata)
