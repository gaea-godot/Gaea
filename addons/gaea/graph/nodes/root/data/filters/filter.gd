@tool
extends GaeaNodeResource

func _get_required_params() -> Array[StringName]:
	return [params[0].name]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	seed(generator_data.generator.seed + salt)

	var input_data: Dictionary = get_arg(params[0].name, area, generator_data)
	var new_data: Dictionary = {}
	for cell: Vector3i in input_data:
		if _passes_filter(input_data, cell, area, generator_data):
			new_data.set(cell, input_data.get(cell))

	return output_port.return_value(new_data)


@warning_ignore("unused_parameter")
func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	return true
