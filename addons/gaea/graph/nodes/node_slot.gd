@tool
class_name GaeaNodeSlot
extends Resource


const SLOT_SCENE = preload("res://addons/gaea/graph/components/slot.tscn")

@export_group("Left", "left")
@export var left_enabled: bool = true
@export var left_type: GaeaGraphNode.SlotTypes
@export var left_label: String = ""
@export_group("Right", "right")
@export var right_enabled: bool = true
@export var right_type: GaeaGraphNode.SlotTypes
@export var right_label: String = ""


func get_node(_graph_node: GaeaGraphNode, _idx: int) -> Control:
	var node := SLOT_SCENE.instantiate()
	node.initialize(_graph_node, _idx)
	node.left_enabled = left_enabled
	node.left_type = left_type
	node.left_label = left_label
	node.right_enabled = right_enabled
	node.right_type = right_type
	node.right_label = right_label
	return node
