@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	if output_port.type == GaeaValue.Type.VECTOR2:
		return output_port.return_value(Vector2(
			get_arg(&"x", area, generator_data),
			get_arg(&"y", area, generator_data),
		))
	elif output_port.type == GaeaValue.Type.VECTOR3:
		return output_port.return_value(Vector3(
			get_arg(&"x", area, generator_data),
			get_arg(&"y", area, generator_data),
			get_arg(&"z", area, generator_data),
		))
	return {}
