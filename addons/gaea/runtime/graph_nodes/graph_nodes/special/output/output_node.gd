@tool
class_name GaeaOutputGraphNode
extends GaeaGraphNode
## The in-editor representation of [GaeaNodeOutput].


func _on_added() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	super()
	custom_minimum_size.x = 192.0

	var titlebar: StyleBoxFlat = get_theme_stylebox("titlebar", "GraphNode").duplicate()
	var titlebar_selected: StyleBoxFlat = (
		get_theme_stylebox("titlebar_selected", "GraphNode").duplicate()
	)
	titlebar.bg_color = titlebar.bg_color.blend(Color(resource.get_title_color(), 0.3))
	titlebar_selected.bg_color = titlebar.bg_color

	add_theme_stylebox_override("titlebar", titlebar)
	add_theme_stylebox_override("titlebar_selected", titlebar_selected)


func update_slots() -> void:
	var layer_count: int = graph_edit.graph.layers.size()
	resource.notify_argument_list_changed()
	for idx in layer_count:
		_connect_layer_resource_signal(idx)

	auto_shrink.call_deferred()


func _connect_layer_resource_signal(idx: int):
	var layer: GaeaLayer = graph_edit.graph.layers[idx]
	if not layer or not is_instance_valid(layer):
		return

	if layer.changed.is_connected(resource.notify_argument_list_changed):
		return

	layer.changed.connect(resource.notify_argument_list_changed)
