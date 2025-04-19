@tool
class_name GaeaGraphNode
extends GraphNode


const PreviewTexture = preload("res://addons/gaea/graph/nodes/preview_texture.gd")


signal save_requested
signal connections_updated

@export var resource: GaeaNodeResource

static var titlebar_styleboxes: Dictionary[GaeaValue.Type, Dictionary]
var generator: GaeaGenerator
## List of connections that goes to this node from other nodes.
## Used by the generator during runtime. This list is updated
## from Panel.update_connections method.
var connections: Array[Dictionary]
var preview: PreviewTexture
var preview_container: VBoxContainer
var finished_loading: bool = false


func _ready() -> void:
	initialize()

	if is_instance_valid(resource):
		set_tooltip_text(GaeaNodeResource.get_formatted_text(resource.description))

	connections_updated.connect(_update_arguments_visibility)


func initialize() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	var preview_button_group: ButtonGroup = ButtonGroup.new()
	preview_button_group.allow_unpress = true

	if resource.salt == 0:
		resource.salt = randi()

	var idx: int = 0
	
	for param in resource.params:
		add_child(param.get_node(self, idx))
		idx += 1

	for output in resource.outputs:
		var node := output.get_node(self, idx)
		add_child(node)
		idx += 1
		if GaeaValue.has_preview(output.type):
			node.toggle_preview_button.show()
			
			if not is_instance_valid(preview):
				preview_container = VBoxContainer.new()
				preview = PreviewTexture.new()
				preview.node = self
				generator.generation_finished.connect(preview.update.unbind(1))

			node.toggle_preview_button.button_group = preview_button_group
			node.toggle_preview_button.toggled.connect(preview.toggle.bind(output).unbind(1))

	if is_instance_valid(preview_container):
		add_child(preview_container)
		preview_container.add_child(preview)
		preview_container.hide()
	title = resource.title
	resource.node = self

	var output_type: GaeaValue.Type = resource.get_type()
	var titlebar: StyleBoxFlat
	var titlebar_selected: StyleBoxFlat
	if output_type != GaeaValue.Type.NULL:
		if not titlebar_styleboxes.has(output_type) or titlebar_styleboxes.get(output_type).get("for_color", Color.TRANSPARENT) != resource.get_title_color():
			titlebar = get_theme_stylebox("titlebar", "GraphNode").duplicate()
			titlebar_selected = get_theme_stylebox("titlebar_selected", "GraphNode").duplicate()
			titlebar.bg_color = titlebar.bg_color.blend(Color(resource.get_title_color(), 0.3))
			titlebar_selected.bg_color = titlebar.bg_color
			titlebar_styleboxes.set(output_type, {"titlebar": titlebar, "selected": titlebar_selected, "for_color": resource.get_title_color()})
		else:
			titlebar = titlebar_styleboxes.get(output_type).get("titlebar")
			titlebar_selected = titlebar_styleboxes.get(output_type).get("selected")
		add_theme_stylebox_override("titlebar", titlebar)
		add_theme_stylebox_override("titlebar_selected", titlebar_selected)


func on_added() -> void:
	pass


func get_connected_node(connection_idx: int) -> GraphNode:
	for connection in connections:
		if connection.to_port == connection_idx:
			return get_parent().get_node(NodePath(connection.from_node))
	return null


func get_connected_port(connection_idx: int) -> int:
	for connection in connections:
		if connection.to_port == connection_idx:
			return connection.from_port
	return -1


func get_arg_value(arg_name: String) -> Variant:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name == arg_name:
				return child.get_param_value()
	return null


func set_arg_value(arg_name: String, value: Variant) -> void:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name == arg_name:
				child.set_param_value(value)
				return


func _on_param_value_changed(_value: Variant, _node: GaeaGraphNodeParameter, _param_name: String) -> void:
	if finished_loading:
		save_requested.emit()
		if is_instance_valid(preview):
			preview.update()


func _update_arguments_visibility() -> void:
	var input_idx: int = -1
	for child in get_children():
		if not is_slot_enabled_left(child.get_index()):
			continue
		input_idx += 1

		if child is GaeaGraphNodeParameter:
			child.set_param_visible(not connections.any(_is_connected_to.bind(input_idx)))

	auto_shrink()


func on_removed() -> void:
	pass


func request_save() -> void:
	save_requested.emit()


func notify_connections_updated() -> void:
	connections_updated.emit()


func _is_connected_to(connection: Dictionary, idx: int) -> bool:
	return connection.to_port == idx and connection.to_node == name


func auto_shrink() -> void:
	size = get_combined_minimum_size()
	# This is used to force the wire to redraw at the correct location
	await get_tree().process_frame
	for i: int in get_child_count():
		slot_updated.emit.call_deferred(i)


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = {
		"name": name,
		"position": position_offset,
		"salt": resource.salt
	}
	if resource.params.size() > 0:
		dictionary.set("data", {})
		for param : GaeaNodeSlotParam in resource.params:
			var value: Variant = get_arg_value(param.name)
			if value == null:
				continue
			if value != param.default_value:
				dictionary.data[param.name] = get_arg_value(param.name)
	return dictionary


func load_save_data(saved_data: Dictionary) -> void:
	if saved_data.has("position"):
		position_offset = saved_data.position
	if saved_data.has("data"):
		var data = saved_data.get("data")
		for child in get_children():
			if child is GaeaGraphNodeParameter:
				if not data.has(child.resource.name):
					data.set(child.resource.name, child.resource.default_value)
				if data.get(child.resource.name) != null:
					child.set_param_value(data[child.resource.name])

	finished_loading = true


func _make_custom_tooltip(for_text: String) -> Object:
	var rich_text_label: RichTextLabel = RichTextLabel.new()
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	rich_text_label.bbcode_enabled = true
	rich_text_label.text = for_text
	rich_text_label.fit_content = true
	rich_text_label.custom_minimum_size.x = 256.0
	return rich_text_label
