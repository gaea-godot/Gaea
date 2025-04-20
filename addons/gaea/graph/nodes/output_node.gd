@tool
extends GaeaGraphNode
## The in-editor representation of [GaeaNodeOutput].


func _on_added() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	title = resource.title
	resource.node = self
	resource.params = []
	for layer in generator.data.layers.size():
		_add_layer_slot(layer)
	auto_shrink.call_deferred()

	var titlebar: StyleBoxFlat = get_theme_stylebox("titlebar", "GraphNode").duplicate()
	var titlebar_selected: StyleBoxFlat = get_theme_stylebox("titlebar_selected", "GraphNode").duplicate()
	titlebar.bg_color = titlebar.bg_color.blend(Color(resource.get_title_color(), 0.3))
	titlebar_selected.bg_color = titlebar.bg_color

	add_theme_stylebox_override("titlebar", titlebar)
	add_theme_stylebox_override("titlebar_selected", titlebar_selected)


func _add_layer_slot(idx: int) -> void:
	var slot_resource: GaeaNodeSlotParam = GaeaNodeSlotParam.new()
	slot_resource.name = "layer_%s" % idx
	slot_resource.type = GaeaValue.Type.MAP
	resource.params.append(slot_resource)
	var node = slot_resource.get_node(self, idx)
	add_child(node)
	_connect_layer_resource_signal(idx)
	if not node.is_node_ready():
		await node.ready


func update_slots() -> void:
	var layer_count: int = generator.data.layers.size()
	if layer_count < get_child_count():
		for i in range(get_child_count(), layer_count, -1):
			var child: Control = get_child(i - 1)
			child.queue_free()
			await child.tree_exited
	elif layer_count > get_child_count():
		for i in range(get_child_count(), layer_count):
			_add_layer_slot(i)

	for idx in layer_count:
		_connect_layer_resource_signal(idx)

	auto_shrink.call_deferred()


func _connect_layer_resource_signal(idx: int):
	var layer: GaeaLayer = generator.data.layers[idx]
	if not layer or not is_instance_valid(layer):
		_on_layer_resource_changed(idx, layer)
		return
	if layer.changed.is_connected(_on_layer_resource_changed):
		_on_layer_resource_changed(idx, layer)
		return

	var node: Node = get_child(idx - 1)
	var callback = _on_layer_resource_changed.bind(idx, layer)
	layer.changed.connect(callback)
	node.tree_exiting.connect(layer.changed.disconnect.bind(callback), CONNECT_ONE_SHOT)
	callback.call_deferred()


func _on_layer_resource_changed(idx: int, layer: GaeaLayer):
	var slot: GaeaGraphNodeParameterEditor = get_child(idx)
	if not is_instance_valid(layer):
		slot.set_label_text("[color=RED](%d) Missing GaeaLayer resource[/color]" % idx)
		return

	if layer.resource_name:
		slot.set_label_text("(%d) %s" % [idx, layer.resource_name])
	else:
		slot.set_label_text("(%d) Layer %s" % [idx, idx])

	if not layer.enabled:
		slot.set_label_text("[color=DIM_GRAY][s]%s[/s][/color]" % slot.get_label_text())
