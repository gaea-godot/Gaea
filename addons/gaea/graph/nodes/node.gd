@tool
class_name GaeaGraphNode
extends GraphNode


const PreviewTexture = preload("res://addons/gaea/graph/nodes/preview_texture.gd")
const PREVIEW_TYPES := [SlotTypes.MAP_DATA, SlotTypes.VALUE_DATA]

enum SlotTypes {
	VALUE_DATA, MAP_DATA, TILE_INFO, VECTOR2, NUMBER, RANGE, BOOL, VECTOR3, NULL = -1
}

signal save_requested
signal connections_updated

@export var resource: GaeaNodeResource

var generator: GaeaGenerator
var connections: Array[Dictionary]
var preview: PreviewTexture
var preview_container: VBoxContainer
var finished_loading: bool = false


func _ready() -> void:
	initialize()

	if is_instance_valid(resource):
		set_tooltip_text(GaeaNodeResource.get_formatted_text(resource.description))


func initialize() -> void:
	if not is_instance_valid(resource):
		return

	var preview_button_group: ButtonGroup = ButtonGroup.new()
	preview_button_group.allow_unpress = true

	if resource.salt == 0:
		resource.salt = randi()

	for input_slot in resource.input_slots:
		add_child(input_slot.get_node())

	for arg in resource.args:
		add_child(arg.get_arg_node())

	for output_slot in resource.output_slots:
		var node: Control = output_slot.get_node()
		add_child(node)
		if output_slot.right_type in PREVIEW_TYPES:
			node.toggle_preview_button.show()

			if not is_instance_valid(preview):
				preview_container = VBoxContainer.new()
				preview = PreviewTexture.new()
				preview.node = self
				preview.resource = resource
				generator.generation_finished.connect(preview.update.unbind(1))

			var output_idx = resource.output_slots.find(output_slot) + resource.args.filter(_has_output_slot).size()
			node.toggle_preview_button.button_group = preview_button_group
			node.toggle_preview_button.toggled.connect(preview.toggle.bind(output_idx, output_slot.right_type).unbind(1))

	if is_instance_valid(preview_container):
		add_child(preview_container)
		preview_container.add_child(preview)
		preview_container.hide()
	title = resource.title
	resource.node = self


func _has_output_slot(arg: GaeaNodeArgument) -> bool:
	return arg.add_output_slot

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


func on_removed() -> void:
	pass


func request_save() -> void:
	save_requested.emit()


func notify_connections_updated() -> void:
	connections_updated.emit()


func get_save_data() -> Dictionary:
	for arg in resource.args:
		resource.data[arg.name] = get_arg_value(arg.name)

	var dictionary: Dictionary = {
		"name": name,
		"position": position_offset
	}
	return dictionary


func load_save_data(data: Dictionary) -> void:
	position_offset = data.position

	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if resource.data.has(child.resource.name):
				child.set_param_value(resource.data[child.resource.name])

	finished_loading = true


static func get_color_from_type(type: SlotTypes) -> Color:
	match type:
		SlotTypes.VALUE_DATA:
			return Color("9c999e")
		SlotTypes.MAP_DATA:
			return Color("45ffa2")
		SlotTypes.TILE_INFO:
			return Color("ff4545")
		SlotTypes.VECTOR2:
			return Color("a579ff")
		SlotTypes.VECTOR3:
			return Color("f9ff79")
		SlotTypes.NUMBER:
			return Color.LIGHT_GRAY
		SlotTypes.RANGE:
			return Color.DIM_GRAY
		SlotTypes.BOOL:
			return Color("3e9c59")
	return Color.WHITE





func _make_custom_tooltip(for_text: String) -> Object:
	var rich_text_label: RichTextLabel = RichTextLabel.new()
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	rich_text_label.bbcode_enabled = true
	rich_text_label.text = for_text
	rich_text_label.fit_content = true
	rich_text_label.custom_minimum_size.x = 256.0
	return rich_text_label
