@tool
extends GaeaNodeResource

func get_data(passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)

	var grids: Array[Dictionary] = []
	for data in passed_data:
		var grid_data: Dictionary = {}
		grids.append(data)

	var grid: Dictionary = {}
	if grids.is_empty():
		return grid

	var grid_a: Dictionary = grids.pop_front()
	for cell: Vector3i in grid_a:
		for subgrid: Dictionary in grids:
			if subgrid.get(cell) != null:
				break
			grid.set(cell, grid_a.get(cell))

	return grid
