@tool
extends GaeaNodeResource


func get_data(passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	log_data(_output_port, generator_data)

	var grid_data: Dictionary = passed_data[0]
	var gradient: GaeaMaterialGradient = passed_data[1].get("value", null)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	if not is_instance_valid(gradient):
		return grid

	for cell in grid_data:
		if grid_data.get(cell) == null:
			continue

		var material: GaeaMaterial = gradient.sample(grid_data.get(cell))
		if is_instance_valid(material):
			grid[cell] = material.get_resource()

	return grid
