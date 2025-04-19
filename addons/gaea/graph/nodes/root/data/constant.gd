@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	return output_port.return_value(get_arg(&"value", area, generator_data))
