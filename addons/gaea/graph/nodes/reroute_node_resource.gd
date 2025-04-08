@tool
extends GaeaNodeResource



# Traversal
func traverse(output_port:int, area: AABB, generator_data:GaeaData) -> Dictionary:
	log_traverse(generator_data)

	# Validation
	if not has_inputs_connected(_get_required_input_ports(), generator_data):
		return {}

	var data_input_resource = get_input_resource(0, generator_data)
	if is_instance_valid(data_input_resource):
		return data_input_resource.traverse(
			get_connected_port_to(0),
			area, generator_data
		)

	return {}


func get_type() -> GaeaGraphNode.SlotTypes:
	return GaeaGraphNode.SlotTypes.NULL


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")
