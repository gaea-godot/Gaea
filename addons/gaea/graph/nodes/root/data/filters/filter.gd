@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0]

func get_data(passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)

	seed(generator_data.generator.seed + salt)

	var new_data: Dictionary = {}
	for cell: Vector3i in passed_data[0]:
		if _passes_filter(passed_data[0], cell, generator_data):
			new_data.set(cell, passed_data[0].get(cell))

	return new_data


func _passes_filter(_passed_data: Dictionary, _cell: Vector3i, _generator_data: GaeaData) -> bool:
	return true
