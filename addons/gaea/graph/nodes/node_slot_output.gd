@tool
class_name GaeaNodeSlotOutput extends GaeaNodeSlot


@export var name: StringName = &"value":
	set(new_value):
		name = new_value
		_update_resource_name()
@export var type: GaeaValue.Type = GaeaValue.Type.NULL:
	set(new_value):
		type = new_value
		_update_resource_name()
		notify_property_list_changed()


func get_node(_graph_node: GaeaGraphNode, _idx: int) -> GaeaGraphNodeOutput:
	var node: GaeaGraphNodeOutput = preload("uid://cqpby5jyv71l0").instantiate()
	node.resource = self
	node.initialize(_graph_node, _idx)
	return node


func return_value(value: Variant) -> Dictionary:
	return {
		"value": value,
		"type": type,
	}
