@tool
extends GaeaNodeResource


func get_data(_passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)
	return {
		"value": {
			"max": get_arg("max", generator_data),
			"min": get_arg("min", generator_data)
		}
	}
