@tool
extends "res://addons/gaea/graph/nodes/root/data/operation.gd"

func _get_required_input_ports(): return [0]

func get_data(passed_data:Array[Dictionary], output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:

	var a_input: Dictionary = passed_data[0]
	var b_input: Dictionary = passed_data[1]

	var new_grid: Dictionary[Vector3i, float]
	for cell: Vector3i in a_input.keys() + b_input.keys():
		new_grid.set(cell, _get_new_value(a_input.get(cell), b_input.get(cell)))

	return new_grid
