@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0, 1]

func get_data(passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	log_data(_output_port, generator_data)

	var grid_data:Dictionary = passed_data[0]
	var material: GaeaMaterial = passed_data[1].get("value", null)

	seed(generator_data.generator.seed + salt)

	var grid: Dictionary[Vector3i, GaeaMaterial]
	var cells_to_place_on: Array = grid_data.keys()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(get_arg("amount", generator_data), cells_to_place_on.size()))

	for cell: Vector3i in cells_to_place_on:
		grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return grid
