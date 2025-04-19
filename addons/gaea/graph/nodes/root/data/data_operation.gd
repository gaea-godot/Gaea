@tool
extends "operation.gd"

func _get_required_params() -> Array[StringName]:
	return [&"data"]

func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data: Dictionary = get_arg(&"data", area, generator_data)
	var value: float = get_arg(&"value", area, generator_data)
	var new_grid: Dictionary[Vector3i, float]
	for cell in data:
		new_grid.set(cell, _get_new_value(data.get(cell), value))

	return output_port.return_value(new_grid)
