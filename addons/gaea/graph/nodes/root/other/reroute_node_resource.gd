@tool
extends GaeaNodeResource

@export var type: GaeaGraphNode.SlotTypes = GaeaGraphNode.SlotTypes.NUMBER


func get_data(_output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data_connected_idx: int = get_connected_resource_idx(0)
	if data_connected_idx == -1:
		return {}
		
	var data_input_resource: GaeaNodeResource = generator_data.resources.get(data_connected_idx)
	if not is_instance_valid(data_input_resource):
		return {}
		
		
	var input: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)

	return input


func get_type() -> GaeaGraphNode.SlotTypes:
	return type


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")
