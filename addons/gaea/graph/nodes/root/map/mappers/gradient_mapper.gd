@tool
extends GaeaNodeResource


func _get_required_params() -> Array[StringName]:
	return [&"data", &"gradient"]


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grid_data: Dictionary = get_arg(&"data", area, generator_data)
	var gradient: GaeaMaterialGradient = get_arg(&"gradient", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	if not is_instance_valid(gradient):
		return grid

	for cell in grid_data:
		if grid_data.get(cell) == null:
			continue

		var material: GaeaMaterial = gradient.sample(grid_data.get(cell))
		if is_instance_valid(material):
			grid[cell] = material.get_resource()

	return output_port.return_value(grid)
