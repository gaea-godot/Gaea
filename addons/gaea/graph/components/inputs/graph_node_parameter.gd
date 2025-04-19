@tool
class_name GaeaGraphNodeParameter
extends Control

@export var connection_idx: int = 0

var add_output_slot: bool = false
var resource: GaeaNodeSlotParam
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
	if is_part_of_edited_scene():
		return

	if resource.default_value != null:
		set_param_value(resource.default_value)

	if not graph_node.is_node_ready():
		await graph_node.ready

	param_value_changed.connect(graph_node._on_param_value_changed.bind(self, resource.name))
	
	if GaeaValue.is_wireable(resource.type):
		graph_node.set_slot_enabled_left(slot_idx, true)
		graph_node.set_slot_type_left(slot_idx, resource.type)
		graph_node.set_slot_color_left(slot_idx, GaeaValue.get_color(resource.type))
		graph_node.set_slot_custom_icon_left(slot_idx, GaeaValue.get_slot_icon(resource.type))
	else:
		# This is required because without it the color of the slots after is OK but not the icon.
		# Probably a Godot issue.
		graph_node.set_slot_enabled_left(slot_idx, false)

	set_label_text(resource.name.capitalize())


func get_param_value() -> Variant:
	return null


func set_param_value(_new_value: Variant) -> void:
	pass


func set_label_text(new_text: String) -> void:
	label.text = new_text


func get_label_text() -> String:
	return label.text


func set_param_visible(value: bool) -> void:
	for child in get_children():
		if child == label:
			continue
		child.set_visible(value)
