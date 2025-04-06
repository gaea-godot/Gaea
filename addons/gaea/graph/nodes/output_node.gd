@tool
extends GaeaGraphNode


func initialize() -> void:
	if not is_instance_valid(resource):
		return

	title = resource.title
	resource.node = self
	for layer in generator.data.layers.size():
		_add_layer_slot(layer)
	_auto_resize.call_deferred()


func _add_layer_slot(idx: int) -> void:
	var slot_resource: GaeaNodeSlot = GaeaNodeSlot.new()
	slot_resource.left_enabled = true
	slot_resource.left_label = "Layer %s" % idx
	slot_resource.left_type = GaeaGraphNode.SlotTypes.MAP_DATA
	slot_resource.right_enabled = false
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

	_auto_resize.call_deferred()

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
	var slot: Node = get_child(idx)
	if not is_instance_valid(layer):
		slot.left_label = "[color=RED](%d) Missing GaeaLayer resource[/color]" % idx
	elif layer.resource_name:
		slot.left_label = "(%d) %s" % [idx, layer.resource_name]
		if not layer.enabled:
			slot.left_label = "[color=DIM_GRAY][s]%s[/s][/color]" % slot.left_label
	else:
		slot.left_label = "(%d) Layer %s" % [idx, idx]


func _auto_resize():
	size.x = get_combined_minimum_size().x
	size.y = get_combined_minimum_size().y
