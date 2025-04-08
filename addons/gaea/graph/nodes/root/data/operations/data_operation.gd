@tool
extends "res://addons/gaea/graph/nodes/root/data/operation.gd"

func _get_required_input_ports(): return [0]

func get_data(passed_data:Array[Dictionary], output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:

	var new_grid: Dictionary[Vector3i, float]
	for cell in passed_data[0]:
		new_grid.set(cell, _get_new_value(passed_data[0].get(cell), get_arg("value", generator_data)))

	return new_grid
