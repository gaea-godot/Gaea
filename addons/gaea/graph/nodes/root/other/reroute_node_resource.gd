@tool
extends GaeaNodeResource


func get_data(_passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data_connected_idx: int = get_connected_resource_idx(0)
	if data_connected_idx == -1:
		return {}
	var data_input_resource: GaeaNodeResource = generator_data.resources.get(data_connected_idx)
	if not is_instance_valid(data_input_resource):
		return {}
	var input: Dictionary = data_input_resource.get_data(
		_passed_data, 0, area, generator_data
	)
	return input


func get_type() -> GaeaGraphNode.SlotTypes:
	if is_instance_valid(node) and node.has(&"type"):
		return node.get(&"type")
	return GaeaGraphNode.SlotTypes.NULL


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")
