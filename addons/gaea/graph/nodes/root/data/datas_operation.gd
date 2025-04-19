@tool
extends "operation.gd"

func _get_required_params() -> Array[StringName]:
	return [&"data_a", &"data_b"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	var a_input: Dictionary = get_arg(&"data_a", area, generator_data)
	var b_input: Dictionary = get_arg(&"data_b", area, generator_data)

	var new_grid: Dictionary[Vector3i, float]
	for cell: Vector3i in a_input.keys() + b_input.keys():
		var a_value = a_input.get(cell)
		var b_value = b_input.get(cell)
		if a_value == null or b_value == null:
			continue
		new_grid.set(cell, _get_new_value(a_value, b_value))

	return output_port.return_value(new_grid)
