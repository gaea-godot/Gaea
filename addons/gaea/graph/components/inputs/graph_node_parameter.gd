@tool
class_name GaeaGraphNodeParameter
extends Control

@export var add_input_slot: bool = true
@export var input_type: GaeaGraphNode.SlotTypes
@export var connection_idx: int = 0

var add_output_slot: bool = false
var resource: GaeaNodeArgument
## Reference to the [GaeaGraphNode] instance
var graph_node: GaeaGraphNode
## ID of the slot in the [GaeaGraphNode].
var slot_idx: int

signal param_value_changed(new_value: Variant)

@onready var label: Label = $Label


func initialize(_graph_node: GaeaGraphNode, _slot_idx: int) -> void:
	graph_node = _graph_node
	slot_idx = _slot_idx


func _ready() -> void:
	if not is_instance_valid(resource):
		return

	if resource.default_value != null:
		set_param_value(resource.default_value)

	if not graph_node.is_node_ready():
		await graph_node.ready

	param_value_changed.connect(graph_node._on_param_value_changed.bind(self, resource.name))

	graph_node.set_slot(
		slot_idx,
		add_input_slot, input_type, GaeaGraphNode.get_color_from_type(input_type),
		add_output_slot, input_type, GaeaGraphNode.get_color_from_type(input_type),
		GaeaGraphNode.get_icon_from_type(input_type), GaeaGraphNode.get_icon_from_type(input_type),
	)

	set_label_text(resource.name.capitalize())


func get_param_value() -> Variant:
	return null


func set_param_value(_new_value: Variant) -> void:
	pass


func set_label_text(new_text: String) -> void:
	label.text = new_text
