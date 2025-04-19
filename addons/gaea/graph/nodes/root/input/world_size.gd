@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	if not is_instance_valid(generator_data.generator):
		return output_port.return_value(Vector3.ZERO)
	return output_port.return_value(Vector3(generator_data.generator.world_size))
