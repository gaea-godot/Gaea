@tool
extends GaeaNodeResource


func get_data(_passed_data:Array[Dictionary], output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)
	var vector = get_arg("vector", generator_data)
	match output_port:
		0:
			return {"value": vector.x}
		1:
			return {"value": vector.y}
		2:
			return {"value": vector.z}
	return {}
