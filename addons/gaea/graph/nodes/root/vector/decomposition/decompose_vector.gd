@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	var vector = get_arg(&"vector", area, generator_data)
	match output_port.name:
		&"x":
			return output_port.return_value(vector.x)
		&"y":
			return output_port.return_value(vector.y)
		&"z":
			return output_port.return_value(vector.z)
	return {}
