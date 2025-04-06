@tool
extends GaeaGraphNodeParameter


@onready var line_edit: LineEdit = $LineEdit


func _ready() -> void:
	await super()
	if not is_instance_valid(resource):
		return

	line_edit.text_changed.connect(param_value_changed.emit)
	graph_node.set_slot_enabled_right(0, true)
	graph_node.set_slot_type_right(0, graph_node.resource.output_type)
	graph_node.set_slot_color_right(0, GaeaGraphNode.get_color_from_type(graph_node.resource.output_type))
	graph_node.set_slot_custom_icon_right(0, GaeaGraphNode.get_icon_from_type(graph_node.resource.output_type))


func get_param_value() -> String:
	if super() != null:
		return super()
	return line_edit.text


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) not in [TYPE_STRING, TYPE_STRING_NAME]:
		return
	line_edit.text = new_value
