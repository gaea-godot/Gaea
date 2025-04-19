@tool
extends GaeaNodeResource

func _get_required_params() -> Array[StringName]:
	return [&"data", &"material"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grid_data: Dictionary = get_arg(&"data", area, generator_data)
	var material: GaeaMaterial = get_arg(&"material", area, generator_data)

	seed(generator_data.generator.seed + salt)

	var grid: Dictionary[Vector3i, GaeaMaterial]
	var cells_to_place_on: Array = grid_data.keys()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(get_arg(&"amount", area, generator_data), cells_to_place_on.size()))

	for cell: Vector3i in cells_to_place_on:
		grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return output_port.return_value(grid)
