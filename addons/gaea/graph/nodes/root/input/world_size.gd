@tool
extends GaeaNodeResource
class_name GaeaNodeWorldSize
## Outputs [member GaeaGenerator.world_size] of the current generator.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	if not is_instance_valid(generator_data.generator):
		return output_port.return_value(Vector3.ZERO)
	return output_port.return_value(Vector3(generator_data.generator.world_size))
